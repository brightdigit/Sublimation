//
//  File.swift
//  
//
//  Created by Leo Dion on 2/2/24.
//

import Foundation
import Sublimation

package actor MockTunnelClient<Key : Sendable> : KVdbTunnelClient {
  package  init(
    getValueResult: Result<URL, any Error>? = nil, saveValueError: (any Error)? = nil
  ) {
    self.getValueResult = getValueResult
    self.saveValueError = saveValueError
  }
  
  package struct GetParameters {
    package let key : Key
    package let bucketName : String
  }
  
  package struct SaveParameters {
    package let value : URL
    package let key : Key
    package let bucketName : String
  }
  
  let getValueResult : Result<URL, any Error>?
  let saveValueError : (any Error)?
  
  package private(set) var getValuesPassed = [GetParameters]()
  package private(set) var saveValuesPassed = [SaveParameters]()
  
  package func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    getValuesPassed.append(.init(key: key, bucketName: bucketName))
    return try self.getValueResult!.get()
  }
  
  package func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    saveValuesPassed.append(.init(value: value, key: key, bucketName: bucketName))
    if let saveValueError {
      throw saveValueError
    }
  }
  
  
  
  
}
extension URL {
  package static func random () -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
  }
}
