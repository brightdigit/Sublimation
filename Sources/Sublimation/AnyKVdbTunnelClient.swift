import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@available(*, deprecated)
public struct AnyKVdbTunnelClient<Key>: KVdbTunnelClient {
  private init(
    client: Any,
    getValue: @escaping (Key, String) async throws -> URL,
    saveValue: @escaping (URL, Key, String) async throws -> Void
  ) {
    self.client = client
    getValueClosure = getValue
    saveValueClosure = saveValue
  }

  public init<TunnelClientType: KVdbTunnelClient>(
    client: TunnelClientType
  ) where TunnelClientType.Key == Self.Key {
    self.init(
      client: client,
      getValue: client.getValue(ofKey:fromBucket:),
      saveValue: client.saveValue(_:withKey:inBucket:)
    )
  }

  let client: Any
  let getValueClosure: (Key, String) async throws -> URL
  let saveValueClosure: (URL, Key, String) async throws -> Void

  public func getValue(
    ofKey key: Key,
    fromBucket bucketName: String
  ) async throws -> URL {
    try await getValueClosure(key, bucketName)
  }

  public func saveValue(
    _ value: URL,
    withKey key: Key,
    inBucket bucketName: String
  ) async throws {
    try await saveValueClosure(value, key, bucketName)
  }
}
