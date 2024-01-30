import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct KVdbTunnelRepositoryFactory<
  Key: Sendable
>: WritableTunnelRepositoryFactory {
  public init(bucketName: String) {
    self.bucketName = bucketName
  }

  public func setupClient<TunnelClientType>(
    _ client: TunnelClientType
  ) -> KVdbTunnelRepository<Key>
    where TunnelClientType: KVdbTunnelClient, TunnelClientType.Key == Key {
    .init(client: client, bucketName: bucketName)
  }

  let bucketName: String
  public typealias TunnelRepositoryType = KVdbTunnelRepository<Key>
}

public protocol TunnelRepositoryFactory: Sendable {
  associatedtype TunnelRepositoryType: TunnelRepository
  func setupClient<
    TunnelClientType: KVdbTunnelClient
  >(
    _ client: TunnelClientType
  ) -> TunnelRepositoryType where TunnelClientType.Key == TunnelRepositoryType.Key
}

public protocol WritableTunnelRepositoryFactory: TunnelRepositoryFactory
  where TunnelRepositoryType: WritableTunnelRepository {}

public protocol WritableTunnelRepository: TunnelRepository {
  func saveURL(_ url: URL, withKey key: Key) async throws
}
