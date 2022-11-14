import Foundation

public class KeyDBTunnelRepository<Key>: WritableTunnelRepository {
 
  

  
  public  init(client: AnyTunnelClient<Key>? = nil, bucketName: String) {
    self.client = client
    self.bucketName = bucketName
  }
  
  var client : AnyTunnelClient<Key>?
  let bucketName : String
  public func setupClient<TunnelClientType : TunnelClient>(_ client: TunnelClientType) where TunnelClientType.Key == Key {
    self.client = client.eraseToAnyClient()
  }
  public func tunnel(forKey key: Key) async throws -> URL? {
    guard let client = self.client else {
      preconditionFailure()
    }
    return try await client.getValue(ofKey: key, fromBucket: bucketName)
    
//    return try await client.get("https://kvdb.io/\(bucketName)/\(key)").body.map(String.init(buffer:)).flatMap(URL.init(string:))
    
  }
  public func saveURL(_ url: URL, withKey key: Key) async throws {
    guard let client = self.client else {
      preconditionFailure()
    }
    try await client.saveValue(url, withKey: key, inBucket: bucketName)
//    _ = try await client.post("https://kvdb.io/\(bucketName)/\(key)", beforeSend: { request in
//      request.body = .init(string: url.absoluteString)
//    })
  }
  
  
}

