import Foundation
import Vapor

public protocol ObsoleteNgrokServer: AnyObject, Sendable, NgrokServer {
  func startHttpTunnel(port: Int) async
  func setupClient(_ client: HTTPClient) async
  func setupLogger(_ logger: Logger) async
  func setDelegate(_ delegate: any NgrokServerDelegate) async
}

extension ObsoleteNgrokServer {
  func startTunnelFor(
    application: Application,
    withDelegate delegate: any NgrokServerDelegate
  ) async {
    await setDelegate(delegate)

    await setupClient(application.http.client.shared)
    await setupLogger(application.logger)
    let port = application.http.server.shared.configuration.port
    await startHttpTunnel(port: port)
  }
}
