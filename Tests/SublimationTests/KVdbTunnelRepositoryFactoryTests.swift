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

import SublimationMocks
import SublimationTunnel
import XCTest

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class KVdbTunnelRepositoryFactoryTests: XCTestCase {
  internal func testSetupClient() async throws {
    let getURLExpected: URL = .random()
    let client = MockTunnelClient<UUID>(
      getValueResult: .success(getURLExpected),
      saveValueError: nil
    )
    let saveKey = UUID()
    let saveURL: URL = .random()

    let getKey = UUID()

    let bucketName = UUID().uuidString
    let factory = TunnelBucketRepositoryFactory<UUID>(bucketName: bucketName)

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
