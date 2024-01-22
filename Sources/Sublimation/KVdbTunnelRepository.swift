import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor KVdbTunnelRepository<Key>: WritableTunnelRepository {
  internal init(client: (any KVdbTunnelClient<Key>)? = nil, bucketName: String) {
    self.client = client
    self.bucketName = bucketName
  }

  public init(bucketName: String) {
    client = nil
    self.bucketName = bucketName
  }

  public init<TunnelClientType: KVdbTunnelClient>(
    client: TunnelClientType,
    bucketName: String
  ) where TunnelClientType.Key == Key {
    self.client = client
    self.bucketName = bucketName
  }

  var client: (any KVdbTunnelClient<Key>)?
  let bucketName: String

  public func setupClient<TunnelClientType: KVdbTunnelClient>(
    _ client: TunnelClientType
  ) async where TunnelClientType.Key == Key {
    self.client = client
  }

  public func tunnel(forKey key: Key) async throws -> URL? {
    guard let client = self.client else {
      preconditionFailure()
    }
    return try await client.getValue(ofKey: key, fromBucket: bucketName)
  }

  public func saveURL(_ url: URL, withKey key: Key) async throws {
    guard let client = self.client else {
      preconditionFailure()
    }
    try await client.saveValue(url, withKey: key, inBucket: bucketName)
  }
}
