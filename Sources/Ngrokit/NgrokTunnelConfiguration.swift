import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokTunnelConfiguration: Codable {
  let addr: URL
  let inspect: Bool
}
