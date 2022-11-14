import Foundation
import Vapor
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
