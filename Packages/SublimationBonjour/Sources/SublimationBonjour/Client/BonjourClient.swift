//
//  BonjourClient.swift
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

#if canImport(Network)
  public import Foundation

  public import Network

  // private import BitnessOpenAPITypes

  #if canImport(os)
    public import os
  #elseif canImport(Logging)
    public import Logging
  #endif

  public actor BonjourClient {
    private let browser: NWBrowser
    private var connections: [UUID: BonjourConnection] = [:]
    private let streams = StreamManager<UUID, URL>()
    private let logger: Logger?

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

    public init(logger: Logger? = nil) {
      assert(logger != nil)
      let descriptor: NWBrowser.Descriptor
      #if os(watchOS)
        descriptor = .bonjourWithTXTRecord(type: "_sublimation._tcp", domain: nil)
      #else
        descriptor = .bonjour(type: "_sublimation._tcp", domain: nil)
      #endif
      let browser = NWBrowser(for: descriptor, using: .tcp)
      self.browser = browser
      self.logger = logger
      browser.browseResultsChangedHandler = { results, _ in
        self.parseResults(results)
      }
    }

    private static func descriptionFor(state: NWConnection.State) -> String {
      switch state {
      case .setup: "setup"
      case .waiting: "waiting"
      case .preparing: "preparing"
      case .ready: "ready"
      case .failed: "failed"
      case .cancelled: "cancelled"
      default: "unknown"
      }
    }

    private func append(urls: [URL]) async {
      await self.streams.yield(urls, logger: self.logger)
    }

    private nonisolated func append(urls: [URL]) {
      Task {
        await self.append(urls: urls)
      }
    }

    public nonisolated func connection(withID id: UUID, received urls: [URL]) {
      Task {
        await self.append(urls: urls)
        await self.removeConnection(withID: id, isOptional: false)
      }
    }

    public nonisolated func connection(withID id: UUID, updatedTo state: NWConnection.State) {
      logger?.debug("Connection Updated \(id): \(BonjourClient.descriptionFor(state: state))")
    }

    public nonisolated func connection(withID id: UUID, failedWithError error: any Error) {
      Task {
        logger?.error("Connection Failed \(id): \(error)")
        await self.removeConnection(withID: id, isOptional: false)
      }
    }

    public nonisolated func cancelledConnection(withID id: UUID) {
      Task {
        logger?.debug("Connection Cancelled \(id)")
        await self.removeConnection(withID: id, isOptional: true)
      }
    }

    public nonisolated func parseResults(_ results: Set<NWBrowser.Result>) {
      Task {
        await self.addResults(results)
      }
    }

    private func removeConnection(withID id: UUID, isOptional: Bool) {
      let value = self.connections.removeValue(forKey: id)
      if !isOptional {
        assert(value != nil)
      }
      value?.cancel()
    }

    @available(*, deprecated, message: "Use BitnessUtlities.")
    enum TXTRecordError: Error {
      case key(String)
      case index(String)
      case indexMismatch(Int)
      case base64Decoding
    }

    @available(*, deprecated, message: "Use BitnessUtlities.")
    private static func bindingConfiguration(txtRecordDictionary: [String: String]) throws
      -> BindingConfiguration {
      let pairs = try txtRecordDictionary.map { (key: String, value: String) in
        let components = key.components(separatedBy: "_")
        guard components.count == 2, components.first == "Sublimation",
              let indexString = components.last
        else {
          throw TXTRecordError.key(key)
        }
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

      guard let data: Data = .init(base64Encoded: values.joined()) else {
        // self.logger?.error("Unable to decode Base64 TXT Record for \(result.endpoint.debugDescription)")
        throw TXTRecordError.base64Decoding
      }

      return try .init(serializedData: data)
    }

    public func addResults(_ results: Set<NWBrowser.Result>) {
      for result in results {
        #if os(watchOS)
          guard case let .bonjour(txtRecord) = result.metadata else {
            self.logger?.error("No TXT Record for \(result.endpoint.debugDescription)")
            continue
          }
          let dictionary = txtRecord.dictionary
          let configuration: BindingConfiguration
          do {
            configuration = try Self.bindingConfiguration(txtRecordDictionary: dictionary)
          } catch {
            self.logger?.error(
              "Failed to parse TXT Record for \(result.endpoint.debugDescription): \(error)")
            continue
          }
          #warning("Defaults should be passed to connection")
          let urls = configuration.urls(defaultIsSecure: false, defaultPort: 8_080)
          self.append(urls: urls)
        #else
          if let connection = BonjourConnection(result: result, client: self) {
            self.connections[connection.id] = connection
          }
        #endif
      }
    }
  }

  extension BonjourClient {
    public func first() async -> URL? {
      for await baseURL in await self.urls {
        return baseURL
      }
      return nil
    }
  }
#endif
