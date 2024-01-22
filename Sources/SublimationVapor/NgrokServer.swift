import Foundation
import Vapor
public protocol NgrokServer: AnyObject, Sendable {
  func startHttpTunnel(port: Int)
  func setupClient(_ client: HTTPClient)
  func setupLogger(_ logger: Logger)
  var delegate: NgrokServerDelegate? { get set }
}

extension NgrokServer {
  func startTunnelFor(
    application: Application,
    withDelegate delegate: NgrokServerDelegate
  ) {
    self.delegate = delegate
    
    setupClient(application.http.client.shared)
    setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    startHttpTunnel(port: port)
  }
}
