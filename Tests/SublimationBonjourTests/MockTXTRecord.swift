//
//  MockTXTRecord.swift
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

internal struct MockTXTRecord: TXTRecord {
  internal let dictionary: [String: String]

  internal var count: Int {
    dictionary.count
  }

  internal init(_ dictionary: [String: String]) {
    self.dictionary = dictionary
  }

  internal func getStringEntry(for key: String) -> String? {
    dictionary[key]
  }
}

private let ipAddresses: [String] = [
  "192.168.0.1", "10.0.0.1", "172.16.254.1", "8.8.8.8",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7334", "fe80::1ff:fe23:4567:890a",
  "2001:0db8:0000:0042:0000:8a2e:0370:7334", "::ffff:192.168.1.1",
  "192.168.0.2", "10.0.0.2", "172.16.254.2", "8.8.4.4",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7335", "fe80::1ff:fe23:4567:890b",
  "2001:0db8:0000:0042:0000:8a2e:0370:7335", "::ffff:192.168.1.2",
  "192.168.0.3", "10.0.0.3", "172.16.254.3", "1.1.1.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7336", "fe80::1ff:fe23:4567:890c",
  "2001:0db8:0000:0042:0000:8a2e:0370:7336", "::ffff:192.168.1.3",
  "192.168.0.4", "10.0.0.4", "172.16.254.4", "9.9.9.9",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7337", "fe80::1ff:fe23:4567:890d",
  "2001:0db8:0000:0042:0000:8a2e:0370:7337", "::ffff:192.168.1.4",
  "192.168.0.5", "10.0.0.5", "172.16.254.5", "1.0.0.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7338", "fe80::1ff:fe23:4567:890e",
  "2001:0db8:0000:0042:0000:8a2e:0370:7338", "::ffff:192.168.1.5",
  "192.168.0.6", "10.0.0.6", "172.16.254.6", "4.2.2.2",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7339", "fe80::1ff:fe23:4567:890f",
  "2001:0db8:0000:0042:0000:8a2e:0370:7339", "::ffff:192.168.1.6",
  "192.168.0.7", "10.0.0.7", "172.16.254.7", "4.2.2.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7340", "fe80::1ff:fe23:4567:8910",
  "2001:0db8:0000:0042:0000:8a2e:0370:7340", "::ffff:192.168.1.7",
  "192.168.0.8", "10.0.0.8", "172.16.254.8", "208.67.222.222",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7341", "fe80::1ff:fe23:4567:8911",
  "2001:0db8:0000:0042:0000:8a2e:0370:7341", "::ffff:192.168.1.8",
  "192.168.0.9", "10.0.0.9", "172.16.254.9", "208.67.220.220",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7342", "fe80::1ff:fe23:4567:8912",
  "2001:0db8:0000:0042:0000:8a2e:0370:7342", "::ffff:192.168.1.9",
  "192.168.0.10", "10.0.0.10", "172.16.254.10", "198.51.100.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7343", "fe80::1ff:fe23:4567:8913",
  "2001:0db8:0000:0042:0000:8a2e:0370:7343", "::ffff:192.168.1.10",
  "192.168.0.11", "10.0.0.11", "172.16.254.11", "203.0.113.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7344", "fe80::1ff:fe23:4567:8914",
  "2001:0db8:0000:0042:0000:8a2e:0370:7344", "::ffff:192.168.1.11",
  "192.168.0.12", "10.0.0.12", "172.16.254.12", "192.0.2.1",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7345", "fe80::1ff:fe23:4567:8915",
  "2001:0db8:0000:0042:0000:8a2e:0370:7345", "::ffff:192.168.1.12",
  "192.168.0.13", "10.0.0.13", "172.16.254.13", "198.51.100.2",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7346", "fe80::1ff:fe23:4567:8916",
  "2001:0db8:0000:0042:0000:8a2e:0370:7346", "::ffff:192.168.1.13",
  "192.168.0.14", "10.0.0.14", "172.16.254.14", "203.0.113.2",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7347", "fe80::1ff:fe23:4567:8917",
  "2001:0db8:0000:0042:0000:8a2e:0370:7347", "::ffff:192.168.1.14",
  "192.168.0.15", "10.0.0.15", "172.16.254.15", "192.0.2.2",
  "2001:0db8:85a3:0000:0000:8a2e:0370:7348", "fe80::1ff:fe23:4567:8918",
  "2001:0db8:0000:0042:0000:8a2e:0370:7348", "::ffff:192.168.1.15"
]

extension Array where Element == String {
  internal static func randomIpAddresses(maxLength: Int) -> Self {
    .init(
      ipAddresses.shuffled().prefix(maxLength)
    )
  }
}
