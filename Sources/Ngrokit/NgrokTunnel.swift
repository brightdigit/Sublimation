import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokTunnel: Codable {
  public let name: String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config: NgrokTunnelConfiguration
}
