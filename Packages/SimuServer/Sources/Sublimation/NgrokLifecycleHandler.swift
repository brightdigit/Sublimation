import Vapor
import Ngrokit
import Prch
import PrchVapor

enum NgrokServerError : Error {
  case clientNotSetup
  case noTunnelFound
}
class NgrokCLIAPIServer : NgrokServer {

  let cli = Ngrok.CLI(executableURL:
      .init(fileURLWithPath:  "/opt/homebrew/bin/ngrok"))
  var client : Prch.Client<SessionClient, Ngrok.API>?
 
  func setupClient(_ client: Vapor.Client) {
    self.client = Prch.Client(api: Ngrok.API(), session: SessionClient(client: client))
  }
  
  var terminationHandler: (@Sendable (Process) -> Void)? {
    get {
      fatalError()
    }
    
    set {
      
    }
  }
  
  func startHttp(port: Int) async throws {
    let client : Prch.Client<SessionClient, Ngrok.API>
    do {
      try await cli.http(port: port, timeout: .now() + 1.0)
      return
    } catch Ngrok.CLI.RunError.earlyTermination(_, let errorCode) where errorCode == 108 {
      guard let ourClient = self.client else {
        throw NgrokServerError.clientNotSetup
      }
      client = ourClient
    } catch {
      throw error
    }
    
    let tunnels = try await client.request(ListTunnelsRequest()).get().response.get().tunnels
    
    if let oldTunnel = tunnels.first {      
      try await client.request(StopTunnelRequest(name: oldTunnel.name)).get().response.get()
    }
    
    let tunnel = try await  client.request(StartTunnelRequest(body: .init(port: port))).get().response.get()
    
    print(tunnel.public_url)
  }
}

public protocol NgrokServer {
  var terminationHandler: (@Sendable (Process) -> Void)? {
    get
    set
  }
  
  func startHttp (port: Int) async throws
  func setupClient(_ client: Vapor.Client)
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
    let port = application.http.server.shared.configuration.port

    _Concurrency.Task {
      do {
        try await self.server.startHttp(port: port)
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

