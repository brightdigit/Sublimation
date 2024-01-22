import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated, renamed: "Tunnel")
public struct NgrokTunnel: Codable, Content {
  public let name: String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config: NgrokTunnelConfiguration
}
