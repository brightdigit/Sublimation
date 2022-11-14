import Foundation
import Vapor


public enum Kvdb {
  
  public static let baseURI : URI = "https://kvdb.io/"
  
  public static let baseURL : URL = URL(staticString: baseURI.string)
  
  public static func uri<Key>(forKey key: Key, atBucket bucketName : String) -> URI {
    var uri = baseURI
    uri.path = "\(bucketName)/\(key)"
    return uri
  }
  
  public static func url<Key>(forKey key: Key, atBucket bucketName : String) -> URL {
    return baseURL.appendingPathComponent("\(bucketName)/\(key)")
  }
  
  
}

