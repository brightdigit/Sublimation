import Foundation


public extension URLSession {
  static func ephemeral () -> URLSession {
    return URLSession(configuration: .ephemeral)
  }
}
public struct URLSessionClient<Key> : KVdbTunnelClient {
  internal init(session: URLSession = .ephemeral()) {
    self.session = session
  }
  
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
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel(nil, nil)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel(httpResponse.statusCode, data)
    }
  }
  
  
}
