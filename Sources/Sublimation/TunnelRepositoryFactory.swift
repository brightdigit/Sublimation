import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol TunnelRepositoryFactory: Sendable {
  associatedtype TunnelRepositoryType: TunnelRepository
  func setupClient<
    TunnelClientType: KVdbTunnelClient
  >(
    _ client: TunnelClientType
  ) -> TunnelRepositoryType where TunnelClientType.Key == TunnelRepositoryType.Key
}
