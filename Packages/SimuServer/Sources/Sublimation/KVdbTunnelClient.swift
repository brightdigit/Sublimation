import Foundation


public protocol KVdbTunnelClient {
  associatedtype Key
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws
}


public extension KVdbTunnelClient {
  func eraseToAnyClient() -> AnyKVdbTunnelClient<Key> {
    return AnyKVdbTunnelClient(client: self)
  }
}
