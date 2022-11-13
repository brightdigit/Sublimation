import Vapor
import Ngrokit
import Prch
import PrchVapor

typealias PrchTask = Prch.Task
typealias Task = _Concurrency.Task
enum NgrokServerError : Error {
  case clientNotSetup
  case noTunnelFound
  case invalidURL
  case cantSaveTunnel
}

protocol ServiceRepository {
  
}
public protocol NgrokServerDelegate {
  func server(_ server: NgrokServer, updatedTunnel tunnel: NgrokTunnel)
  func server(_ server: NgrokServer, errorDidOccur error: Error)
  func server(_ server: NgrokServer, failedWithError error: Error)
}
class NgrokCLIAPIServer : NgrokServer {
  
  let cli = Ngrok.CLI(executableURL:
      .init(fileURLWithPath:  "/opt/homebrew/bin/ngrok"))
  var prchClient : Prch.Client<SessionClient, Ngrok.API>!
  var port : Int?
  var logger : Logger!
  var ngrokProcess : Process? {
    didSet {
      self.ngrokProcess?.terminationHandler = self.ngrokProcessTerminated
    }
  }
  
  
  var delegate : NgrokServerDelegate?
  
  func setupLogger(_ logger: Logger) {
    self.logger = logger
  }
  
  func ngrokProcessTerminated(_ process: Process) {
    guard let port = self.port else {
      return
    }
    
    self.startHttpTunnel(port: port)
  }
  
  func setupClient(_ client: Vapor.Client) {    
    self.prchClient = Prch.Client(api: Ngrok.API(), session: SessionClient(client: client))
  }
  
  public enum TunnelError : Error{
    case noTunnelCreated
  }
  
  func startHttpTunnel(port: Int) {
    Task {
      let tunnel : NgrokTunnel
      do {
         tunnel = try await self.startHttp(port: port)
      } catch {
        self.delegate?.server(self, failedWithError: error)
        return
      }
      self.delegate?.server(self, updatedTunnel: tunnel)
    }
  }
  
  func startHttp(port: Int) async throws -> NgrokTunnel {
    self.port = port
    self.logger.debug("Starting Ngrok Tunnel...")
    let tunnels: [NgrokTunnel]
    
    
    if let firstCallTunnels = try? await self.prchClient.request(ListTunnelsRequest()).get().response.get().tunnels {
      tunnels = firstCallTunnels
    } else {      
      do {
        let ngrokProcess = try await cli.http(port: port, timeout: .now() + 1.0)
        
        guard let tunnel = try await self.prchClient.request(ListTunnelsRequest()).get().response.get().tunnels.first else {
          ngrokProcess.terminate()
          throw TunnelError.noTunnelCreated
        }
        self.ngrokProcess = ngrokProcess
        self.logger.debug("Created Ngrok Process...")
        return tunnel
      } catch Ngrok.CLI.RunError.earlyTermination(_, let errorCode) where errorCode == 108 {
        self.logger.debug("Ngrok Process Already Created.")
      } catch {
        self.logger.debug("Error thrown: \(error.localizedDescription)")
        throw error
      }
      
      self.logger.debug("Listing Tunnels")
      tunnels = try await prchClient.request(ListTunnelsRequest()).get().response.get().tunnels
    }
    
    
    
    if let oldTunnel = tunnels.first {
      self.logger.debug("Deleting Existing Tunnel: \(oldTunnel.public_url) ")
      try await prchClient.request(StopTunnelRequest(name: oldTunnel.name)).get().response.get()
    }
    
    self.logger.debug("Creating Tunnel...")
    let tunnel = try await prchClient.request(StartTunnelRequest(body: .init(port: port))).get().response.get()
    
    return tunnel
    //let status = try app.http.client.shared.post(url: "https://kvdb.io/\(bucketName)/\(serverName)", body: .string(tunnel.public_url.absoluteString)).wait().status
  }
}

public protocol NgrokServer : AnyObject {
  
  func startHttpTunnel (port: Int)
  func setupClient(_ client: Vapor.Client)
  func setupLogger(_ logger: Logger)
  var delegate : NgrokServerDelegate? { get set }
}

extension NgrokServer {
  func startTunnelFor(application: Application, withDelegate delegate: NgrokServerDelegate) {
    self.delegate = delegate
    self.setupClient(application.client)
    self.setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    self.startHttpTunnel(port: port)
  }
}

public protocol TunnelRepository {
  associatedtype Key
  func tunnel(forKey key: Key) async throws -> URL?
}

public protocol WritableTunnelRepository : TunnelRepository {
  func setupClient<TunnelClientType : TunnelClient>(_ client: TunnelClientType) where TunnelClientType.Key == Self.Key
  func saveURL(_ url: URL, withKey key: Key) async throws
}

public protocol TunnelClient {
  associatedtype Key
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws
}

extension TunnelClient {
  func eraseToAnyClient() -> AnyTunnelClient<Key> {
    return AnyTunnelClient(client: self)
  }
}

public struct AnyTunnelClient<Key> : TunnelClient {
  private init(client: Any, _getValue: @escaping (Key, String) async throws -> URL, _saveValue: @escaping (URL, Key, String) async throws -> Void) {
    self.client = client
    self._getValue = _getValue
    self._saveValue = _saveValue
  }
  
  public init<TunnelClientType : TunnelClient>(client : TunnelClientType) where TunnelClientType.Key == Self.Key {
    self.init(client: client, _getValue: client.getValue(ofKey:fromBucket:), _saveValue: client.saveValue(_:withKey:inBucket:))
  }
  
  let client : Any
  let _getValue : ( Key,  String) async throws -> URL
  let _saveValue : (URL, Key, String) async throws -> Void
  
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    try await self._getValue(key, bucketName)
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    try await self._saveValue(value, key, bucketName)
  }
  
  
}


public struct URLSessionClient<Key> : TunnelClient {
  let session : URLSession
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let data = try await session.data(from: Kvdb.url(forKey: key, atBucket: bucketName)).0
    
    guard let url = String(data: data, encoding: .utf8).flatMap(URL.init(string:)) else {
      throw NgrokServerError.invalidURL
    }
    
    return url
    
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    var request = URLRequest(url: Kvdb.url(forKey: key, atBucket: bucketName))
    request.httpBody = value.absoluteString.data(using: .utf8)
    guard let response = try await session.data(for: request).1 as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel
    }
    guard response.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel
    }
  }
  
  
}

public struct VaporTunnelClient<Key> : TunnelClient {
  internal init(client: Vapor.Client, keyType: Key.Type) {
    self.client = client
  }
  
  let client : Vapor.Client
  
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let url = try await client.get("https://kvdb.io/\(bucketName)/\(key)").body.map(String.init(buffer:)).flatMap(URL.init(string:))
    
    guard let url = url else {
      throw NgrokServerError.invalidURL
    }
    return url
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    
    _ = try await client.post("https://kvdb.io/\(bucketName)/\(key)", beforeSend: { request in
      request.body = .init(string: value.absoluteString)
  })
                              }
  
  
}


public enum Kvdb {
  
  public static let baseURI : URI = "https://kvdb.io/"
  
  public static let baseURL : URL = URL(staticString: baseURI.string)
  
  public static func uri<Key>(forKey key: Key, atBucket bucketName : String) -> URI {
    var uri = baseURI
    uri.path = "\(bucketName)/\(key)"
    return uri
  }
  
  public static func url<Key>(forKey key: Key, atBucket bucketName : String) -> URL {
    return baseURL.appendingPathComponent("\(bucketName)/\(key)")
  }
  
  
}
public class KeyDBTunnelRepository<Key>: WritableTunnelRepository {
 
  

  
  internal init(client: AnyTunnelClient<Key>? = nil, bucketName: String) {
    self.client = client
    self.bucketName = bucketName
  }
  
  var client : AnyTunnelClient<Key>?
  let bucketName : String
  public func setupClient<TunnelClientType : TunnelClient>(_ client: TunnelClientType) where TunnelClientType.Key == Key {
    self.client = client.eraseToAnyClient()
  }
  public func tunnel(forKey key: Key) async throws -> URL? {
    guard let client = self.client else {
      preconditionFailure()
    }
    return try await client.getValue(ofKey: key, fromBucket: bucketName)
    
//    return try await client.get("https://kvdb.io/\(bucketName)/\(key)").body.map(String.init(buffer:)).flatMap(URL.init(string:))
    
  }
  public func saveURL(_ url: URL, withKey key: Key) async throws {
    guard let client = self.client else {
      preconditionFailure()
    }
    try await client.saveValue(url, withKey: key, inBucket: bucketName)
//    _ = try await client.post("https://kvdb.io/\(bucketName)/\(key)", beforeSend: { request in
//      request.body = .init(string: url.absoluteString)
//    })
  }
  
  
}

public class NgrokLifecycleHandler<TunnelRepositoryType : WritableTunnelRepository> : LifecycleHandler, NgrokServerDelegate {
  public func server(_ server: NgrokServer, updatedTunnel tunnel: Ngrokit.NgrokTunnel) {
    Task {
      do {
        try await self.tunnelRepo.saveURL(tunnel.public_url, withKey: self.key)
      } catch {
        self.logger?.error("Unable to save url to repository: \(error.localizedDescription)")
      }
    }
  }
  
  public func server(_ server: NgrokServer, errorDidOccur error: Error) {
    
  }
  
  public func server(_ server: NgrokServer, failedWithError error: Error) {
    
  }
  

  public init(server: NgrokServer, repo: TunnelRepositoryType, key: TunnelRepositoryType.Key) {
    self.server = server
    self.tunnelRepo = repo
    self.key = key
  }
  
  let server : NgrokServer
  let tunnelRepo : TunnelRepositoryType
  let key: TunnelRepositoryType.Key
  var logger : Logger?
  
  public func didBoot(_ application: Application) throws {
//
//    server.setupClient(application.client)
//    server.setupLogger(application.logger)
//    let port = application.http.server.shared.configuration.port
    self.logger = application.logger
    self.server.startTunnelFor(application: application, withDelegate: self)
    self.tunnelRepo.setupClient(
      VaporTunnelClient(
        client:  application.client,
        keyType: TunnelRepositoryType.Key.self
      ).eraseToAnyClient()
    )
//    Task {
//      do {
//        let tunnel = try await self.server.startHttp(port: port)
//        application.logger.notice("Tunnel started on \(tunnel.public_url)")
//      } catch {
//        dump(error)
//      }
//    }
    
  }
  
  public func shutdown(_ application: Application) {
    
  }
}

public extension NgrokLifecycleHandler {
  convenience init<Key>(bucketName: String, key: Key) where TunnelRepositoryType == KeyDBTunnelRepository<Key> {

    self.init(server: NgrokCLIAPIServer(), repo: .init(bucketName: bucketName), key: key)
  }
}
//  let serverName = "hello"
//  let bucketName = "4WwQUN9AZrppSyLkbzidgo"
//  let ngrokServer : NgrokServer
//  //let ngrokProcess : Process
//  var port : Int? = nil
//  var isShutdown : Bool = false
//  let decoder = JSONDecoder()
//  let encoder = JSONEncoder()
//
//
//  init (ngrokServer: NgrokServer) {
//    self.ngrokServer = ngrokServer
//    let ngrokProcess = Process ()
////    ngrokProcess.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ngrok")
////    self.ngrokProcess = ngrokProcess
//    //ngrokProcess.terminationHandler = self.processTerminated(_:)
//    self.ngrokServer.terminationHandler = self.processTerminated(_:)
//  }
//
//  func createTunnel () throws -> NgrokTunnel? {
//    guard let port = self.port else {
//      return nil
//    }
//
//    //let data = try encoder.encode(NgrokTunnelRequest(port: port))
//
//    return try app.client.post(.init(stringLiteral: NgrokUrlParser.defaultApiURL.absoluteString), content: NgrokTunnelRequest(port: port)).flatMapThrowing { clientResponse in
//      print(clientResponse.body.map(String.init))
//     return try clientResponse.content.decode(NgrokTunnel.self)
//    }.wait()
//  }
//  func processTerminated (_ process: Process) {
//    guard !isShutdown else {
//      return
//    }
//
//    let response = try? app.http.client.shared.get(url: NgrokUrlParser.defaultApiURL.absoluteString).flatMapThrowing { [self] response -> NgrokTunnelResponse? in
//      guard let body = response.body else {
//        return nil
//      }
//
//      return try decoder.decode(NgrokTunnelResponse.self, from: body)
//    }.wait()
//
//    guard let response = response, let port = self.port else {
//      return
//    }
//
//    guard let tunnel = response.tunnels.first else {
//      do {
//        let tunnel = try self.createTunnel()
//        guard let tunnel = tunnel else {
//          return
//        }
//        try self.saveResponse(tunnel)
//      } catch {
//        dump(error)
//      }
//      return
//    }
//    if tunnel.config.addr.port == port {
//      do {
//        let status = try app.http.client.shared.post(url: "https://kvdb.io/\(bucketName)/\(serverName)", body: .string(tunnel.public_url.absoluteString)).wait().status
//        print(status)
//      } catch {
//        dump(error)
//      }
//    } else {
//      do {
//        try app.http.client.shared.delete(url: NgrokUrlParser.defaultApiURL.appendingPathComponent(tunnel.name).absoluteString).wait()
//        let tunnel = try self.createTunnel()
//        guard let tunnel = tunnel else {
//          return
//        }
//        try self.saveResponse(tunnel)
//        //try self.startTunnel()
//      } catch {
//        dump(error)
//      }
//
//    }
//  }
//
//  fileprivate func saveResponse(_ tunnel: NgrokTunnel) throws {
//    let url = tunnel.public_url
//      let status = try app.http.client.shared.post(url: "https://kvdb.io/\(bucketName)/\(serverName)", body: .string(url.absoluteString)).wait().status
//      print(status)
//
//  }
//
//  fileprivate func startTunnel() throws {
//    guard let port = port else {
//      return
//    }
//    ngrokProcess.arguments = ["http", port.description]
//
//    try ngrokProcess.run()
//
//
//    let response = try app.http.client.shared.get(url: NgrokUrlParser.defaultApiURL.absoluteString).flatMapThrowing { response -> NgrokTunnelResponse? in
//      guard let body = response.body else {
//        return nil
//      }
//
//      return try self.decoder.decode(NgrokTunnelResponse.self, from: body)
//    }.wait()
//
//    guard let tunnel = response?.tunnels.first else {
//      return
//    }
//    try saveResponse(tunnel)
//  }
//
//   func saveTunnel (_ application: Application) throws {
//
//    let port = application.http.server.shared.configuration.port
//    self.port = port
//     self.ngrokServer.startTunnel(forPort: port)
//  }
//   func didBoot(_ application: Application) throws {
//
//    try self.saveTunnel(application)
//
//  }
//   func shutdown(_ application: Application) {
//
//    //self.ngrokProcess.terminate()
//     self.ngrokServer.shutdown()
//    self.isShutdown = true
//  }
//

