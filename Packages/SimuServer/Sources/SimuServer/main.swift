import Vapor
import SublimationVapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}
try configure(app)
app.lifecycle.use(NgrokLifecycleHandler<KeyDBTunnelRepository>(
  bucketName: "4WwQUN9AZrppSyLkbzidgo", key: "hello"
))
try app.start()

//
//class NgrokLifecycleHandler : LifecycleHandler {
//  let serverName = "hello"
//  let bucketName = "4WwQUN9AZrppSyLkbzidgo"
//  let ngrokProcess : Process
//  var port : Int? = nil
//  var isShutdown : Bool = false
//  let decoder = JSONDecoder()
//  let encoder = JSONEncoder()
//
//  init () {
//    let ngrokProcess = Process ()
//    ngrokProcess.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/ngrok")
//    self.ngrokProcess = ngrokProcess
//    self.ngrokProcess.terminationHandler = self.processTerminated(_:)
//  }
//
//  func createTunnel () throws -> NgrokTunnel? {
//    guard let port = self.port else {
//      return nil
//    }
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
//    try startTunnel()
//  }
//   func didBoot(_ application: Application) throws {
//    try self.saveTunnel(application)
//
//  }
//   func shutdown(_ application: Application) {
//
//    self.ngrokProcess.terminate()
//    self.isShutdown = true
//  }
//
//}



try app.running?.onStop.wait()
