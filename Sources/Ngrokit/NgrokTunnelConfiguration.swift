import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokTunnelConfiguration: Codable {
  public let addr: URL
  public let inspect: Bool
}
