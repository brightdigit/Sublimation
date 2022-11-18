import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol KVdbTunnelClient {
  associatedtype Key
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws
}

extension KVdbTunnelClient {
  public func eraseToAnyClient() -> AnyKVdbTunnelClient<Key> {
    AnyKVdbTunnelClient(client: self)
  }
}
