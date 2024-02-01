//
//  KVdbTunnelRepositoryFactoryTests.swift
//  Sublimation
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Sublimation
import XCTest

actor MockTunnelClient<Key : Sendable> : KVdbTunnelClient {
  internal init(
    getValueResult: Result<URL, any Error>? = nil, saveValueError: (any Error)? = nil
  ) {
    self.getValueResult = getValueResult
    self.saveValueError = saveValueError
  }
  
  struct GetParameters {
    let key : Key
    let bucketName : String
  }
  
  struct SaveParameters {
    let value : URL
    let key : Key
    let bucketName : String
  }
  
  let getValueResult : Result<URL, any Error>?
  let saveValueError : (any Error)?
  
  var getValuesPassed = [GetParameters]()
  var saveValuesPassed = [SaveParameters]()
  
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    getValuesPassed.append(.init(key: key, bucketName: bucketName))
    return try self.getValueResult!.get()
  }
  
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    saveValuesPassed.append(.init(value: value, key: key, bucketName: bucketName))
    if let saveValueError {
      throw saveValueError
    }
  }
  
  
  
  
}
extension URL {
  static func random () -> URL {
    URL(filePath: NSTemporaryDirectory())
  }
}
class KVdbTunnelRepositoryFactoryTests: XCTestCase {

  func testSetupClient() async throws {
    let getURLExpected : URL = .random()
    let client = MockTunnelClient<UUID>(
      getValueResult: .success(getURLExpected),
      saveValueError: nil
    )
    let saveKey = UUID()
    let saveURL : URL = .random()
    
    let getKey  = UUID()
    
    let bucketName = UUID().uuidString
    let factory = KVdbTunnelRepositoryFactory<UUID>(bucketName: bucketName)
    
    let repository = factory.setupClient(client)
    
    try await repository.saveURL(saveURL, withKey: saveKey)
    let getURLActual = try await repository.tunnel(forKey: getKey)
    
    let savedValue = await client.saveValuesPassed.last
    XCTAssertEqual(saveKey, savedValue?.key)
    XCTAssertEqual(saveURL, savedValue?.value)
    XCTAssertEqual(bucketName, savedValue?.bucketName)
    
    let getValue = await client.getValuesPassed.last
    XCTAssertEqual(getKey, getValue?.key)
    XCTAssertEqual(bucketName, getValue?.bucketName)
    
    XCTAssertEqual(getURLActual, getURLExpected)
  }
}
