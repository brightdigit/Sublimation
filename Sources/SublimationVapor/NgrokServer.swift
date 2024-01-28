import Foundation
import Vapor

public protocol NgrokServer: AnyObject, Sendable {
  func startHttpTunnel(port: Int) async
  func setupClient(_ client: HTTPClient) async
  func setupLogger(_ logger: Logger) async
  func setDelegate(_ delegate: NgrokServerDelegate) async
}

extension NgrokServer {
  func startTunnelFor(
    application: Application,
    withDelegate delegate: NgrokServerDelegate
  ) async {
    await setDelegate(delegate)

    await setupClient(application.http.client.shared)
    await setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    await startHttpTunnel(port: port)
  }
}
