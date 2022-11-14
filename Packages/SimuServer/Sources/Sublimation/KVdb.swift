import Foundation
public protocol KVdbURLConstructable {
  init(kvDBBase : String, keyBucketPath: String)
}



public enum KVdb {
  public static let baseString = "https://kvdb.io/"
  
  public static func path<Key>(forKey key: Key, atBucket bucketName : String) -> String {
    return "\(bucketName)/\(key)"
  }
  
  public static func construct<Key, URLType: KVdbURLConstructable>(_ type: URLType.Type, forKey key: Key, atBucket bucketName : String) -> URLType {
    URLType.init(
      kvDBBase: Self.baseString,
      keyBucketPath: Self.path(forKey: key, atBucket: bucketName)
    )
  }
}
