import Foundation
public protocol KVdbURLConstructable {
  init(kvDBBase: String, keyBucketPath: String)
}
