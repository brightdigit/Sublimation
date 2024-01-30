import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public final class KVdbTunnelRepository<Key: Sendable>: WritableTunnelRepository {
  init(client: any KVdbTunnelClient<Key>, bucketName: String) {
    self.client = client
    self.bucketName = bucketName
  }

  let client: any KVdbTunnelClient<Key>
  let bucketName: String

  public static func setupClient<TunnelClientType: KVdbTunnelClient>(
    _: TunnelClientType
  ) where TunnelClientType.Key == Key {}

  public func tunnel(forKey key: Key) async throws -> URL? {
    try await client.getValue(ofKey: key, fromBucket: bucketName)
  }

  public func saveURL(_ url: URL, withKey key: Key) async throws {
    try await client.saveValue(url, withKey: key, inBucket: bucketName)
  }
}
