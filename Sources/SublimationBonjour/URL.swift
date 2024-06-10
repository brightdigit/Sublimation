//
//  URL.swift
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

extension URL {
  internal init?(scheme: String, host: String, port: Int) {
    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.port = port
    guard let url = components.url else {
      return nil
    }
    self = url
  }
}

#if canImport(Network)
  import Network

  extension URL {
    internal static func urls(
      from txtRecord: NWTXTRecord,
      logger: LoggingActor?,
      defaultPort: Int,
      defaultTLS: Bool
    ) -> [URL] {
      let configuration = NWTXTRecord.URLConfiguration(
        from: txtRecord,
        logger: logger,
        defaultPort: defaultPort,
        defaultTLS: defaultTLS
      )
      logger?.log { $0.debug("Parsing \(configuration.count) Addresses") }
      return (0 ..< configuration.count).compactMap { index -> URL? in
        let host: String? = txtRecord.getEntry(for: .address(index)).value
        assert(host != nil)
        guard let host else {
          logger?.log { $0.debug("Invalid Address At Index: \(index)") }
          return nil
        }
        return URL(scheme: configuration.scheme, host: host, port: configuration.port)
      }
    }
  }

  extension NWTXTRecord {
    fileprivate struct URLConfiguration {
      let scheme: String
      let port: Int
      let count: Int
    }
  }

  extension NWTXTRecord.URLConfiguration {
    private init(from txtRecord: NWTXTRecord, logger: LoggingActor?, port: Int, isTLS: Bool, offset: Int) {
      let scheme = isTLS ? "https" : "http"
      logger?.log { $0.debug("Scheme: \(scheme)") }
      let addressCount = txtRecord.count - offset
      self.init(scheme: scheme, port: port, count: addressCount)
    }

    fileprivate init(
      from txtRecord: NWTXTRecord,
      logger: LoggingActor?,
      defaultPort: Int,
      defaultTLS: Bool
    ) {
      var offset = 0

      let portEntry = txtRecord.getEntry(for: .port, of: Int.self)
      let port = portEntry.value ?? defaultPort
      offset += portEntry.isEmpty ? 0 : 1

      if let invalidPortEntryString = portEntry.invalidEntryString {
        assert(portEntry.invalidEntryString == nil, "Port Entry is invalid: \(invalidPortEntryString)")
        logger?.log { $0.warning("Port Entry is invalid: \(invalidPortEntryString)") }
      }

      let tlsEntry = txtRecord.getEntry(for: .tls, of: Bool.self)
      let isTLS = tlsEntry.value ?? defaultTLS
      offset += tlsEntry.isEmpty ? 0 : 1

      if let invalidTLSEntryString = tlsEntry.invalidEntryString {
        assert(tlsEntry.invalidEntryString == nil, "Port Entry is invalid: \(invalidTLSEntryString)")
        logger?.log { $0.warning("Port Entry is invalid: \(invalidTLSEntryString)") }
      }

      self.init(from: txtRecord, logger: logger, port: port, isTLS: isTLS, offset: offset)
    }
  }
#endif
