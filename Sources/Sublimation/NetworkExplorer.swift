//
//  NetworkExplorer.swift
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
import Network

#if canImport(Logging)
  import Logging
#else
  import os.log
#endif

public final actor NetworkExplorer {
  private let browser: NetworkBrowser
  let queue: DispatchQueue = .global()
  private let logger: LoggingActor?
  private let streams = StreamManager()

  public init(
    bonjourWithType type: String = "_http._tcp",
    domain: String = "local.",
    using parameters: NWParameters = .tcp,
    logger: (@Sendable () -> Logger)?
  ) {
    self.init(for: .bonjourWithTXTRecord(type: type, domain: domain), using: parameters, logger: logger)
  }

  init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters, logger: (@Sendable () -> Logger)?) {
    self.init(browser: .init(for: descriptor, using: parameters), logger: logger)
  }

  private init(browser: NetworkBrowser, logger: (@Sendable () -> Logger)?) {
    self.logger = logger.map(LoggingActor.init(logger:))
    self.browser = browser
  }

  private static func urls(from result: NWBrowser.Result, logger: LoggingActor?) -> [URL]? {
    guard case .service = result.endpoint else {
      logger?.log { $0.debug("Not service.") }
      return nil
    }
    guard case let .bonjour(txtRecord) = result.metadata else {
      logger?.log { $0.debug("No txt record.") }
      return nil
    }
    var offset = 0
    var port = 80
    var isTLS = false
    if let portValue: Int = txtRecord.getEntry(for: .port) {
      port = portValue
      logger?.log { $0.debug("Found port: \(portValue)") }
      offset += 1
    }
    if let boolValue: Bool = txtRecord.getEntry(for: .tls) {
      isTLS = boolValue
      logger?.log { $0.debug("Found TLS: \(boolValue)") }
      offset += 1
    }
    let scheme = isTLS ? "https" : "http"
    logger?.log { $0.debug("Scheme: \(scheme)") }
    let addressCount = txtRecord.count - offset
    logger?.log { $0.debug("Parsing \(addressCount) Addresses") }
    return (0 ..< addressCount).compactMap { index -> URL? in
      guard let host: String = txtRecord.getEntry(for: .address(index)) else {
        logger?.log { $0.debug("Invalid Address At Index: \(index)") }
        return nil
      }
      var components = URLComponents()
      components.scheme = scheme
      components.host = host
      components.port = port
      return components.url
    }
  }

  private func parseResult(_ result: NWBrowser.Result) {
    guard let urls = Self.urls(from: result, logger: logger) else {
      return
    }
    let logger = logger
    let streams = streams
    Task {
      await streams.yield(urls, logger: logger)
    }
  }

  public var urls: AsyncStream<URL> {
    get async {
      let browser = browser
      let streams = streams
      if await self.streams.isEmpty {
        logger?.log { $0.debug("Starting Browser.") }

        await browser.start(queue: queue, parser: { result in
          Task {
            await self.parseResult(result)
          }
        })
      }
      return AsyncStream { continuation in
        Task {
          await streams.append(continuation) {
            await browser.stop()
            self.logger?.log { $0.debug("Shuting down browser.") }
          }
        }
      }
    }
  }
}
