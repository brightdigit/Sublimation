import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URL: KVdbURLConstructable {
  public init(kvDBBase: String, keyBucketPath: String) {
    // swiftlint:disable:next force_unwrapping
    self = URL(string: kvDBBase)!.appendingPathComponent(keyBucketPath)
  }
}
