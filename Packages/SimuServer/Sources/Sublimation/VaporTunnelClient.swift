import Vapor
import Foundation
public struct VaporTunnelClient<Key> : TunnelClient {
  internal init(client: Vapor.Client, keyType: Key.Type) {
    self.client = client
  }
  
  let client : Vapor.Client
  
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let url = try await client.get("https://kvdb.io/\(bucketName)/\(key)").body.map(String.init(buffer:)).flatMap(URL.init(string:))
    
    guard let url = url else {
      throw NgrokServerError.invalidURL
    }
    return url
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    
    _ = try await client.post("https://kvdb.io/\(bucketName)/\(key)", beforeSend: { request in
      request.body = .init(string: value.absoluteString)
  })
                              }
  
  
}
