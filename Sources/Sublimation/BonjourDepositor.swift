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

#if canImport(os)
  import os
#elseif canImport(Logging)
  import Logging
#endif

public actor BonjourDepositor {
  public static let defaultPort = 80
  public static let defaultTLS = false

  private let browser: NetworkBrowser
  private let queue: DispatchQueue = .global()
  private let logger: LoggingActor?
  private let streams = StreamManager<UUID, URL>()

  private let defaultPort: Int
  private let defaultTLS: Bool

  public var state: NWBrowser.State? {
    get async {
      await self.browser.currentState
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

  public init(
    bonjourWithType type: String = "_http._tcp",
    domain: String = "local.",
    using parameters: NWParameters = .tcp,
    defaultPort: Int = defaultPort,
    defaultTLS: Bool = defaultTLS,
    logger: (@Sendable () -> Logger)? = nil
  ) {
    self.init(
      for: .bonjourWithTXTRecord(type: type, domain: domain),
      using: parameters,
      defaultPort: defaultPort,
      defaultTLS: defaultTLS,
      logger: logger
    )
  }

  public init(
    for descriptor: NWBrowser.Descriptor,
    using parameters: NWParameters,
    defaultPort: Int = defaultPort,
    defaultTLS: Bool = defaultTLS,
    logger: (@Sendable () -> Logger)? = nil
  ) {
    self.init(
      browser: .init(for: descriptor, using: parameters),
      logger: logger,
      defaultPort: defaultPort,
      defaultTLS: defaultTLS
    )
  }

  private init(
    browser: NetworkBrowser,
    logger: (@Sendable () -> Logger)?,
    defaultPort: Int,
    defaultTLS: Bool
  ) {
    self.logger = logger.map(LoggingActor.init(logger:))
    self.browser = browser
    self.defaultTLS = defaultTLS
    self.defaultPort = defaultPort
  }

  private static func urls(
    from result: NWBrowser.Result,
    logger: LoggingActor?,
    defaultPort: Int,
    defaultTLS: Bool
  ) -> [URL]? {
    guard case .service = result.endpoint else {
      logger?.log { $0.debug("Not service.") }
      return nil
    }
    guard case let .bonjour(txtRecord) = result.metadata else {
      logger?.log { $0.debug("No txt record.") }
      return nil
    }
    return URL.urls(from: txtRecord, logger: logger, defaultPort: defaultPort, defaultTLS: defaultTLS)
  }

  private func parseResult(_ result: NWBrowser.Result) {
    guard let urls = Self.urls(
      from: result,
      logger: logger,
      defaultPort: defaultPort,
      defaultTLS: defaultTLS
    ) else {
      return
    }
    let logger = logger
    let streams = streams
    Task {
      await streams.yield(urls, logger: logger)
    }
  }
}
