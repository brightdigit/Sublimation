import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokTunnel: Codable, Content {
  public let name: String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config: NgrokTunnelConfiguration
}
