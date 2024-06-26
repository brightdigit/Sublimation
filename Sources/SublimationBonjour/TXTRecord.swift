//
//  TXTRecord.swift
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

internal protocol TXTRecord {
  var count: Int { get }
  init(_ dictionary: [String: String])
  func getStringEntry(for key: String) -> String?
  func getKeys() -> any Sequence<String>
}

extension TXTRecord {
  private init(_ dictionary: [SublimationKey: any CustomStringConvertible]) {
    self.init(.init(sublimationTxt: dictionary))
  }

  internal init(
    isTLS: Bool,
    port: Int,
    maximumCount: Int?,
    addresses: @autoclosure () -> [String],
    filter: @Sendable @escaping (String) -> Bool
  ) {
    var dictionary: [SublimationKey: any CustomStringConvertible] = [
      .tls: isTLS,
      .port: port
    ]

    let allAddresses = addresses()
    let addresses: any Sequence<String> = if let maximumCount {
      allAddresses.prefix(maximumCount)
    } else {
      allAddresses
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

  internal func getEntry<T: SublimationValue>(for key: SublimationKey, of _: T.Type) -> EntryResult<T> {
    guard let string = getStringEntry(for: key.stringValue) else {
      return .empty
    }
    return .init(string: string)
  }

  internal func getEntry<T: SublimationValue>(for key: SublimationKey) -> EntryResult<T> {
    self.getEntry(for: key, of: T.self)
  }

  internal func urls(
    defaultPort: Int,
    defaultTLS: Bool,
    logger: LoggingActor?
  ) -> [URL] {
    let configuration = self.urlConfiguration(
      logger: logger,
      defaultPort: defaultPort,
      defaultTLS: defaultTLS
    )
    guard let configuration else {
      return []
    }
    logger?.log { $0.debug("Parsing \(configuration.count) Addresses") }
    return (0 ..< configuration.count).compactMap { index -> URL? in
      let host: String? = self.getEntry(for: .address(index)).value
      assert(host != nil)
      guard let host else {
        logger?.log { $0.debug("Invalid Address At Index: \(index)") }
        return nil
      }
      return URL(scheme: configuration.scheme, host: host, port: configuration.port)
    }
  }

  private func urlConfiguration(
    at offset: Int,
    port: Int,
    isTLS: Bool,
    logger: LoggingActor?
  ) -> URL.Configuration {
    let scheme = isTLS ? "https" : "http"
    logger?.log { $0.debug("Scheme: \(scheme)") }
    let addressCount = self.count - offset
    return .init(scheme: scheme, port: port, count: addressCount)
  }

  private func urlConfiguration(
    logger: LoggingActor?,
    defaultPort: Int,
    defaultTLS: Bool
  ) -> URL.Configuration? {
    var offset = 0

    let portEntry = self.getEntry(for: .port, of: Int.self)
    let port = portEntry.value ?? defaultPort
    offset += portEntry.isEmpty ? 0 : 1

    if let invalidPortEntryString = portEntry.invalidEntryString {
      assert(portEntry.invalidEntryString == nil, "Port Entry is invalid: \(invalidPortEntryString)")
      logger?.log { $0.warning("Port Entry is invalid: \(invalidPortEntryString)") }
    }

    let tlsEntry = self.getEntry(for: .tls, of: Bool.self)
    let isTLS = tlsEntry.value ?? defaultTLS
    offset += tlsEntry.isEmpty ? 0 : 1

    if let invalidTLSEntryString = tlsEntry.invalidEntryString {
      assert(tlsEntry.invalidEntryString == nil, "Port Entry is invalid: \(invalidTLSEntryString)")
      logger?.log { $0.warning("Port Entry is invalid: \(invalidTLSEntryString)") }
    }

    let isValid = self.getKeys().allSatisfy { key in
      SublimationKey.isValid(key)
    }

    guard isValid else {
      return nil
    }

    return self.urlConfiguration(at: offset, port: port, isTLS: isTLS, logger: logger)
  }
}
