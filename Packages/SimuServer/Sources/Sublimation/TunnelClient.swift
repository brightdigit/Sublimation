import Foundation


public protocol TunnelClient {
  associatedtype Key
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws
}


public extension TunnelClient {
  func eraseToAnyClient() -> AnyTunnelClient<Key> {
    return AnyTunnelClient(client: self)
  }
}
