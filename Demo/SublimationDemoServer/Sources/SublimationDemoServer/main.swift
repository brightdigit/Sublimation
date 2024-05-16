import SublimationDemoConfiguration
import Network
import SublimationVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer {
  app.shutdown()
}

app.get { _ in
  "You're connected"
}

extension Vapor.Application : SublimationVapor.Application {
  public func post(to url: URL, body: Data?) async throws {
    
    _ = try await client.post(.init(string: url.absoluteString)) { request in
      request.body = body.map(ByteBuffer.init(data:))
    }
  }
  
  public var httpServerConfigurationPort: Int {
    self.http.server.configuration.port
  }
  
  public var httpServerTLS: Bool {
    self.http.server.configuration.tlsConfiguration != nil
  }
  
  public func get(from url: URL) async throws -> Data? {
    let response = try await client.get(.init(string: url.absoluteString))
    return response.body.map{ Data(buffer: $0 )}
  }
  
  
}
extension Sublimation : LifecycleHandler {
  public func willBoot(_ application: Vapor.Application) throws {
    Task {
     self.willBoot{application}
    }
  }
  
  public func didBoot(_ application: Vapor.Application) throws {
    Task {
      self.didBoot{application}
    }
    
  }
  
  public func shutdown(_ application: Vapor.Application) {
    Task {
      self.shutdown{application}
    }
  }
}

app.lifecycle.use(
  Sublimation()
)

//#if os(macOS)
//if let name = Host.current().addresses.first(where: { address in
//  guard address != "127.0.0.1" else {
//    return false
//  }
//  return !address.contains(":")
//}) {
//}
//#endif

app.http.server.configuration.hostname = "::"
try app.run()
