import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct AnyKVdbTunnelClient<Key>: KVdbTunnelClient {
  private init(client: Any, _getValue: @escaping (Key, String) async throws -> URL, _saveValue: @escaping (URL, Key, String) async throws -> Void) {
    self.client = client
    self._getValue = _getValue
    self._saveValue = _saveValue
  }

  public init<TunnelClientType: KVdbTunnelClient>(client: TunnelClientType) where TunnelClientType.Key == Self.Key {
    self.init(client: client, _getValue: client.getValue(ofKey:fromBucket:), _saveValue: client.saveValue(_:withKey:inBucket:))
  }

  let client: Any
  let _getValue: (Key, String) async throws -> URL
  let _saveValue: (URL, Key, String) async throws -> Void

  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    try await _getValue(key, bucketName)
  }

  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    try await _saveValue(value, key, bucketName)
  }
}
