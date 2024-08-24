//
//  BonjourClient.swift
//  SublimationBonjour
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

#if canImport(Network)
  public import Foundation

  import Network

  #if canImport(os)
    public import os
  #elseif canImport(Logging)
    public import Logging
  #endif

  /// Client for fetching the url of the host server.
  ///
  /// On the device, create a ``BonjourClient`` and either get an `AsyncStream` of `URL` objects or just ask for the first one:
  /// ```
  /// let depositor = BonjourClient(logger: app.logger)
  /// let hostURL = await depositor.first()
  /// ```
  public actor BonjourClient {
    private let browser: NWBrowser
    private let streams = StreamManager<UUID, URL>()
    private let logger: Logger?
    private let defaultURLConfiguration: URLDefaultConfiguration

    /// AsyncStream of `URL` from the network.
    public var urls: AsyncStream<URL> {
      get async {
        let browser = browser
        let streams = streams
        let logger = self.logger
        if await self.streams.isEmpty {
          logger?.debug("Starting Browser.")
          browser.start(queue: .global())
        }
        return AsyncStream { continuation in
          Task {
            await streams.append(continuation) {
              logger?.debug("Shutting down browser.")
              browser.cancel()
            }
          }
        }
      }
    }

    /// Creates a BonjourClient for fetching the host urls availab.e
    /// - Parameters:
    ///   - logger: Logger
    ///   - defaultURLConfiguration: default ``URL`` configuration for missing properties.
    public init(logger: Logger? = nil, defaultURLConfiguration: URLDefaultConfiguration = .init()) {
      assert(logger != nil)
      let descriptor: NWBrowser.Descriptor
      descriptor = .bonjourWithTXTRecord(type: "_sublimation._tcp", domain: nil)

      let browser = NWBrowser(for: descriptor, using: .tcp)
      self.defaultURLConfiguration = defaultURLConfiguration
      self.browser = browser
      self.logger = logger
      browser.browseResultsChangedHandler = { results, _ in self.parseResults(results) }
    }

    private func append(urls: [URL]) async { await self.streams.yield(urls, logger: self.logger) }

    private nonisolated func append(urls: [URL]) { Task { await self.append(urls: urls) } }

    private nonisolated func parseResults(_ results: Set<NWBrowser.Result>) {
      Task { await self.addResults(results) }
    }

    private func addResults(_ results: Set<NWBrowser.Result>) {
      for result in results {
        guard case .bonjour(let txtRecord) = result.metadata else {
          self.logger?.error("No TXT Record for \(result.endpoint.debugDescription)")
          continue
        }
        let dictionary = txtRecord.dictionary
        let configuration: BindingConfiguration
        do { configuration = try BindingConfiguration(txtRecordDictionary: dictionary) }
        catch {
          self.logger?
            .error("Failed to parse TXT Record for \(result.endpoint.debugDescription): \(error)")
          continue
        }
        let urls = configuration.urls(defaults: self.defaultURLConfiguration)
        self.append(urls: urls)
      }
    }
  }

  extension BonjourClient {
    /// First URL for the network.
    /// - Returns: the first url
    public func first() async -> URL? {
      for await baseURL in await self.urls { return baseURL }
      return nil
    }
  }
#endif
