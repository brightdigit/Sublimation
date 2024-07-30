//
//  TXTRecordTests.swift
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

import Foundation
@testable import SublimationBonjour
import XCTest

internal class TXTRecordTests: XCTestCase {
  internal func testBadRecord() {
    let record = MockTXTRecord(["Serial Number": UUID().uuidString])
    let urls = record.urls(defaultPort: 0, defaultTLS: false, logger: nil)

    XCTAssert(urls.isEmpty)
  }

  internal func testInit() {
    let expectation = expectation(description: "Filter")

    let expectedIsTLS: Bool = .random()
    let expectedPort: Int = .random(in: 1_000 ... 9_000)
    let expectedAddresses: [String] = .randomIpAddresses(maxLength: 5)

    expectation.expectedFulfillmentCount = expectedAddresses.count

    let record = MockTXTRecord(
      isTLS: expectedIsTLS,
      port: expectedPort,
      maximumCount: nil,
      addresses: expectedAddresses,
      filter: { _ in
        expectation.fulfill()
        return true
      }
    )

    XCTAssertEqual(record.dictionary[SublimationKey.port.stringValue], expectedPort.description)
    XCTAssertEqual(record.dictionary[SublimationKey.tls.stringValue], expectedIsTLS.description)

    for (index, expectedAddress) in expectedAddresses.enumerated() {
      XCTAssertEqual(record.dictionary[SublimationKey.address(index).stringValue], expectedAddress)
    }

    XCTAssertEqual(record.count, expectedAddresses.count + 2)

    wait(for: [expectation], timeout: 1.0)
  }

  internal func testGetEntry() {
    let expectedIsTLS: Bool = .random()
    let expectedPort: Int = .random(in: 1_000 ... 9_000)
    let expectedAddresses: [String] = .randomIpAddresses(maxLength: 5)

    let record = MockTXTRecord(
      isTLS: expectedIsTLS,
      port: expectedPort,
      maximumCount: nil,
      addresses: expectedAddresses,
      filter: { _ in
        true
      }
    )

    XCTAssertEqual(record.getEntry(for: .port).value, expectedPort)
    XCTAssertEqual(record.getEntry(for: .tls).value, expectedIsTLS)

    for (index, expectedAddress) in expectedAddresses.enumerated() {
      XCTAssertEqual(record.getEntry(for: .address(index)).value, expectedAddress)
    }
  }

  internal func testURLs() {
    let expectedIsTLS: Bool = .random()
    let expectedPort: Int = .random(in: 1_000 ... 9_000)
    let expectedAddresses: [String] = .randomIpAddresses(maxLength: 5)

    let record = MockTXTRecord(
      isTLS: expectedIsTLS,
      port: expectedPort,
      maximumCount: nil,
      addresses: expectedAddresses,
      filter: String.isIPv4NotLocalhost(_:)
    )

    let urls = record.urls(defaultPort: 0, defaultTLS: !expectedIsTLS, logger: nil)
    let expectedURLs = expectedAddresses.compactMap { host -> URL? in
      guard String.isIPv4NotLocalhost(host) else {
        return nil
      }
      return URL(scheme: expectedIsTLS ? "https" : "http", host: host, port: expectedPort)
    }

    XCTAssertEqual(urls, expectedURLs)
  }
}
