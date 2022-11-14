import Vapor
import Foundation
import Sublimation

public struct VaporTunnelClient<Key> : KVdbTunnelClient {
  internal init(client: Vapor.Client, keyType: Key.Type) {
    self.client = client
  }
  
  let client : Vapor.Client
  
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)
    let url = try await client.get(uri).body.map(String.init(buffer:)).flatMap(URL.init(string:))
    
    guard let url = url else {
      throw NgrokServerError.invalidURL
    }
    return url
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)
    _ = try await client.post(uri, beforeSend: { request in
      request.body = .init(string: value.absoluteString)
  })
                              }
  
  
}
