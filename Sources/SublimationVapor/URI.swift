import Foundation
import Sublimation
import Vapor

extension URI: KVdbURLConstructable {
  public init(kvDBBase: String, keyBucketPath: String) {
    self.init(string: kvDBBase)
    path = keyBucketPath
  }
}
