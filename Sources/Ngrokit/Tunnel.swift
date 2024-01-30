import Foundation
import NgrokOpenAPIClient

public struct Tunnel: Sendable {
  public let name: String
  public let publicURL: URL
  public let config: NgrokTunnelConfiguration
}

extension Tunnel {
  init(response: Components.Schemas.TunnelResponse) throws {
    guard let publicURL = URL(string: response.public_url) else {
      throw RuntimeError.invalidURL(response.public_url)
    }
    guard let addr = URL(string: response.config.addr) else {
      throw RuntimeError.invalidURL(response.config.addr)
    }
    self.init(
      name: response.name,
      publicURL: publicURL,
      config: .init(
        addr: addr,
        inspect: response.config.inspect
      )
    )
  }
}
