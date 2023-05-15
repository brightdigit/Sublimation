import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum KVdb {
  public static let baseString = "https://kvdb.io/"

  public static func path<Key>(forKey key: Key, atBucket bucketName: String) -> String {
    "\(bucketName)/\(key)"
  }

  public static func construct<Key, URLType: KVdbURLConstructable>(
    _: URLType.Type,
    forKey key: Key,
    atBucket bucketName: String
  ) -> URLType {
    URLType(
      kvDBBase: Self.baseString,
      keyBucketPath: Self.path(forKey: key, atBucket: bucketName)
    )
  }

  public static func url<Key>(
    withKey key: Key,
    atBucket bucketName: String,
    using session: URLSession = .ephemeral()
  ) async throws -> URL? {
    let repository = KVdbTunnelRepository<Key>(
      client: URLSessionClient<Key>(session: session),
      bucketName: bucketName
    )
    return try await repository.tunnel(forKey: key)
  }
}
