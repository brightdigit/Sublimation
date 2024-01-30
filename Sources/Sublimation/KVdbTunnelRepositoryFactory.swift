import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct KVdbTunnelRepositoryFactory<
  Key: Sendable
>: WritableTunnelRepositoryFactory {
  public typealias TunnelRepositoryType = KVdbTunnelRepository<Key>

  public let bucketName: String

  public init(bucketName: String) {
    self.bucketName = bucketName
  }

  public func setupClient<TunnelClientType>(
    _ client: TunnelClientType
  ) -> KVdbTunnelRepository<Key>
    where TunnelClientType: KVdbTunnelClient, TunnelClientType.Key == Key {
    .init(client: client, bucketName: bucketName)
  }
}
