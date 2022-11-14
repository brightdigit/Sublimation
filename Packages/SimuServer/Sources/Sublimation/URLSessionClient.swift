import Foundation


public struct URLSessionClient<Key> : TunnelClient {
  let session : URLSession
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    let data = try await session.data(from: url).0
    
    guard let url = String(data: data, encoding: .utf8).flatMap(URL.init(string:)) else {
      throw NgrokServerError.invalidURL
    }
    
    return url
    
  }
  
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    var request = URLRequest(url: url)
    request.httpBody = value.absoluteString.data(using: .utf8)
    guard let response = try await session.data(for: request).1 as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel
    }
    guard response.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel
    }
  }
  
  
}
