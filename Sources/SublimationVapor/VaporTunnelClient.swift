import Foundation
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct VaporTunnelClient<Key>: KVdbTunnelClient {
  internal init(client: Vapor.Client, keyType _: Key.Type) {
    self.client = client
  }

  let client: Vapor.Client

  public func getValue(
    ofKey key: Key,
    fromBucket bucketName: String
  ) async throws -> URL {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)
    let url: URL?
    if #available(macOS 12, *) {
      url = try await client.get(uri)
        .body
        .map(String.init(buffer:))
        .flatMap(URL.init(string:))
    } else {
      url = try await client
        .get(uri)
        .map {
          $0.body.map(String.init(buffer:)).flatMap(URL.init(string:))
        }.get()
    }

    guard let url = url else {
      throw NgrokServerError.invalidURL
    }
    return url
  }

  public func saveValue(
    _ value: URL,
    withKey key: Key,
    inBucket bucketName: String
  ) async throws {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)
    let response = try await client.post(uri, beforeSend: { request in
      request.body = .init(string: value.absoluteString)
    }).get()

    if response.statusCode / 100 == 2 {
      return
    }

    throw NgrokServerError.cantSaveTunnel(response.statusCode, response.data)
  }
}
