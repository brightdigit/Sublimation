import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokTunnelConfiguration: Sendable {
  public let addr: URL
  public let inspect: Bool
}
