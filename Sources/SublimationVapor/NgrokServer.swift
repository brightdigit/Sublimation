import Foundation
import Vapor
public protocol NgrokServer: AnyObject, Sendable {
  func startHttpTunnel(port: Int)
  func setupClient(_ client: HTTPClient) async
  func setupLogger(_ logger: Logger)
  var delegate: NgrokServerDelegate? { get set }
}

extension NgrokServer {
  func startTunnelFor(
    application: Application,
    withDelegate delegate: NgrokServerDelegate
  ) async {
    self.delegate = delegate
    
    await setupClient(application.http.client.shared)
    setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    startHttpTunnel(port: port)
  }
}
