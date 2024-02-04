
/// A type representing a Uniform Resource Identifier (URI).
///
/// - Note: This type conforms to `KVdbURLConstructable` protocol.
///
/// - SeeAlso: `KVdbURLConstructable`
import Foundation
import Sublimation
import Vapor

extension URI: KVdbURLConstructable {
  ///   Initializes a URI with the given KVDB base and key bucket path.
  ///
  ///   - Parameters:
  ///     - kvDBBase: The base URL of the KVDB.
  ///     - keyBucketPath: The path to the key bucket.
  ///
  ///   - Returns: A new URI instance.
  public init(kvDBBase: String, keyBucketPath: String) {
    self.init(string: kvDBBase)
    path = keyBucketPath
  }
}
