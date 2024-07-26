//
//  String.swift
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

public import Foundation

extension String {
  internal func isLocalhost() -> Bool {
    let localhostNames = ["localhost", "127.0.0.1", "::1"]
    return localhostNames.contains(self)
  }

  internal func isValidIPv6Address() -> Bool {
    var sin6 = sockaddr_in6()
    return self.withCString { cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) } == 1
  }

  internal func formatIPv6ForURL() -> String {
    if isValidIPv6Address() {
      "[\(self)]"
    } else {
      self
    }
  }

  /// Filters strings which are only v4 and not refering the localhost.
  /// - Parameter address: The host address string.
  /// - Returns: True, if the address passes the filter.
  @available(*, deprecated)
  @Sendable
  public static func isIPv4NotLocalhost(_ address: String) -> Bool {
    guard !(["127.0.0.1", "::1", "localhost"].contains(address)) else {
      return false
    }
    guard !address.contains(":") else {
      return false
    }
    return true
  }
}

extension Data {
  public struct DictionaryPrefix {
    let separator: String
    let expectedValue: String?
  }

  public enum TXTRecordError: Error {
    case key(String)
    case index(String)
    case mismatchKeyPrefix(String)
    case indexMismatch(Int)
    case base64Decoding
  }
  static private func indexString(fromKey key: String, withPrefix prefix: DictionaryPrefix?) throws
    -> String
  {
    guard let prefix else {
      return key
    }
    let components = key.components(separatedBy: prefix.separator)
    guard components.count == 2, let indexString = components.last, let keyPrefix = components.first
    else {
      throw TXTRecordError.key(key)
    }
    if let expectedValue = prefix.expectedValue {
      guard keyPrefix == expectedValue else {
        throw TXTRecordError.mismatchKeyPrefix(keyPrefix)
      }
    }
    return indexString
  }
  public init(txtRecordDictionary: [String: String], prefix: DictionaryPrefix?) throws {
    let pairs = try txtRecordDictionary.map { (key: String, value: String) in
      let indexString = try Self.indexString(fromKey: key, withPrefix: prefix)
      guard let index = Int(indexString) else {
        throw TXTRecordError.index(indexString)
      }
      return (index, value)
    }
    .sorted {
      $0.0 < $1.0
    }

    let keys = pairs.map(\.0)

    var lastIndex: Int?
    for index in keys {
      if let lastIndex {
        guard index == lastIndex + 1 else {
          throw TXTRecordError.indexMismatch(index)
        }
      } else {
        guard index == 0 else {
          throw TXTRecordError.indexMismatch(index)
        }
      }
      lastIndex = index
    }

    let values = pairs.map(\.1)

    guard let data = Data(base64Encoded: values.joined()) else {
      throw TXTRecordError.base64Decoding
    }

    self = data
  }
}

extension String {
  func splitByMaxLength(_ maxLength: Int) -> [String] {
    var result: [String] = []
    var currentIndex = self.startIndex

    while currentIndex < self.endIndex {
      let endIndex =
        self.index(currentIndex, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
      let substring = String(self[currentIndex..<endIndex])
      result.append(substring)
      currentIndex = endIndex
    }

    return result
  }
}
extension Dictionary where Key == String, Value == String {
  public init(
    txtRecordData: Data,
    maximumValueSize: Int,
    separator: String = "_",
    keyPrefix: String? = nil
  ) {
    let txtRecordValues = txtRecordData.base64EncodedString().splitByMaxLength(maximumValueSize)
    self = txtRecordValues.enumerated().reduce(into: [String: String]()) {
      result, value in
      let key = [keyPrefix, value.offset.description]
        .compactMap { $0 }
        .joined(separator: separator)
      result[key] = String(value.element)
    }
  }
}
