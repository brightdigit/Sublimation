//
//  NWTXTRecord.swift
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

import Network

extension NWTXTRecord {
  private init(_ dictionary: [SublimationKey: any CustomStringConvertible]) {
    self.init(.init(sublimationTxt: dictionary))
  }

  public init(
    isTLS: Bool,
    port: Int,
    maximumCount: Int?,
    filter: @Sendable @escaping (String) -> Bool,
    addresses: @autoclosure () -> [String]
  ) {
    var dictionary: [SublimationKey: any CustomStringConvertible] = [
      .tls: isTLS,
      .port: port
    ]

    let allAddresses = addresses()
    let addresses: any Sequence<String>
    if let maximumCount {
      addresses = allAddresses.prefix(maximumCount)
    } else {
      addresses = allAddresses
    }
    for address in addresses {
      guard filter(address) else {
        continue
      }
      let index = dictionary.count - 2
      dictionary[.address(index)] = address
    }
    self.init(dictionary)
  }

  public func getEntry<T: SublimationValue>(for key: SublimationKey) -> T? {
    guard case let .string(string) = getEntry(for: key.stringValue) else {
      return nil
    }
    return T(string)
  }
}
