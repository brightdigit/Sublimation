import Vapor
import Ngrokit
import Prch
import PrchVapor

typealias PrchTask = Prch.Task
typealias Task = _Concurrency.Task
enum NgrokServerError : Error {
  case clientNotSetup
  case noTunnelFound
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
  
  func setupLogger(_ logger: Logger) {
    self.logger = logger
  }
  
  func ngrokProcessTerminated(_ process: Process) {
    guard let port = self.port else {
      return
    }
    
    _Concurrency.Task {
      do {
        dump(try await self.startHttp(port: port))
      } catch {
        dump(error)
      }
    }
  }
  
  func setupClient(_ client: Vapor.Client) {    
    self.prchClient = Prch.Client(api: Ngrok.API(), session: SessionClient(client: client))
  }
  
  public enum TunnelError : Error{
    case noTunnelCreated
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

public protocol NgrokServer {
  
  func startHttp (port: Int) async throws -> NgrokTunnel
  func setupClient(_ client: Vapor.Client)
  func setupLogger(_ logger: Logger)
}

public class NgrokLifecycleHandler : LifecycleHandler {
  public init() {
    self.server = NgrokCLIAPIServer()
  }
  public init(server: NgrokServer) {
    self.server = server
  }
  
  let server : NgrokServer
  
  
  public func didBoot(_ application: Application) throws {
    
    server.setupClient(application.client)
    server.setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    
    
    Task {
      do {
        let tunnel = try await self.server.startHttp(port: port)
        application.logger.notice("Tunnel started on \(tunnel.public_url)")
      } catch {
        dump(error)
      }
    }
    
  }
  
  public func shutdown(_ application: Application) {
    
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

