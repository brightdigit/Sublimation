import Vapor
import Foundation
import Sublimation

extension URI : KVdbURLConstructable {
  public init(kvDBBase: String, keyBucketPath: String) {
    self.init(string: kvDBBase)
    self.path = keyBucketPath
  }
}
