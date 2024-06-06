
import Vapor
import protocol Sublimation.Application
import typealias Sublimation.Logger


typealias SublimationApplication = Sublimation.Application

extension Vapor.Application : SublimationApplication {
  public var logger: Sublimation.Logger {
    self.logger
  }
  
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
