import Foundation

extension URL: KVdbURLConstructable {
  public init(kvDBBase: String, keyBucketPath: String) {
    self = URL(string: kvDBBase)!.appendingPathComponent(keyBucketPath)
  }
}
