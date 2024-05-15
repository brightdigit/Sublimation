//
//  File.swift
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
import os.log

enum URLScheme: String {
  case http
  case https
}

extension [String: String] {
  public init(sublimationTxt: [SublimationKey: any CustomStringConvertible]) {
    let pairs = sublimationTxt.map { (key: SublimationKey, value: any CustomStringConvertible) in
      (key.stringValue, value.description)
    }
    self.init(uniqueKeysWithValues: pairs)
  }
}

public enum SublimationKey: Hashable {
  case tls
  case port
  case address(Int)
}

extension SublimationKey {
  var stringValue: String {
    let value: (any CustomStringConvertible)?
    switch self {
    case let .address(index):
      value = index
    default:
      value = nil
    }
    let prefix = SublimationKeyValues(key: self).rawValue
    guard let value else {
      return prefix
    }
    return [prefix, value.description].joined(separator: "_")
  }
}

enum SublimationKeyValues: String {
  case tls = "Sublimation_TLS"
  case port = "Sublimation_Port"
  case address = "Sublimation_Address"
}

extension SublimationKeyValues {
  init(key: SublimationKey) {
    switch key {
    case .address:
      self = .address
    case .port:
      self = .port
    case .tls:
      self = .tls
    }
  }
}

public protocol SublimationValue: CustomStringConvertible {
  init?(_ string: String)
}

extension Bool: SublimationValue {}

extension Int: SublimationValue {}

extension String: SublimationValue {}

extension NWTXTRecord {
  init(_ dictionary: [SublimationKey: any CustomStringConvertible]) {
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

private actor NetworkBrowser {
  public init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters) {
    let browser = NWBrowser(for: descriptor, using: parameters)
    self.init(browser: browser)
    browser.stateUpdateHandler = { state in
      Task {
        await self.onUpdateState(state)
      }
    }
    browser.browseResultsChangedHandler = { newResults, changes in
      Task {
        await self.onResultsChanged(to: newResults, withChanges: changes)
      }
    }
  }

  private init(browser: NWBrowser) {
    self.browser = browser
  }

  func start(queue: DispatchQueue, parser: @Sendable @escaping (NWBrowser.Result) -> Void) {
    browser.start(queue: queue)
    parseResult = parser
  }

  func onUpdateState(_ state: NWBrowser.State) {
    currentState = state
  }

  func onResultsChanged(to _: Set<NWBrowser.Result>, withChanges changes: Set<NWBrowser.Result.Change>) {
    guard let parseResult else {
      return
    }
    for change in changes {
      switch change {
      case let .added(result):
        parseResult(result)
      case .removed:
        break
      case .changed(old: _, new: let new, flags: .metadataChanged):
        parseResult(new)
      case .identical:
        break
      case .changed:
        break
      @unknown default:
        break
      }
    }
  }

  func stop() {
    browser.stateUpdateHandler = nil
    browser.cancel()
  }

  var currentState: NWBrowser.State?
  let browser: NWBrowser
  var parseResult: ((NWBrowser.Result) -> Void)?
}

private actor StreamManager {
  private var streamContinuations = [UUID: AsyncStream<URL>.Continuation]()

  func yield(_ urls: [URL], logger: LoggingActor?) {
    if streamContinuations.isEmpty {
      logger?.log{$0.debug("Missing Continuations.")}
      
    }
    for streamContinuation in streamContinuations {
      for url in urls {
        streamContinuation.value.yield(url)
      }
      logger?.log{$0.debug("Yielded to Stream \(streamContinuation.key)")}
    }
  }

  private func onTerminationOf(_ id: UUID) -> Bool {
    streamContinuations.removeValue(forKey: id)
    return streamContinuations.isEmpty
  }

  public var isEmpty: Bool {
    streamContinuations.isEmpty
  }

  public func append(_ continuation: AsyncStream<URL>.Continuation, onCancel: @Sendable @escaping () async -> Void) {
    let id = UUID()
    streamContinuations[id] = continuation
    continuation.onTermination = { _ in
      // self.logger?.debug("Removing Stream \(id)")
      Task {
        let shouldCancel =
          await self.onTerminationOf(id)

        // self.streamContinuations.removeValue(forKey: id)

        if shouldCancel {
          await onCancel()
        }
      }
    }
  }
}

private actor LoggingActor {
  internal init(logger: @escaping @Sendable () -> Logger) {
    self.logger = logger()
  }
  
  let logger : Logger
  
  private func logWith (_ closure: @Sendable @escaping (Logger) -> Void) {
    Task {
      closure(self.logger)
    }
  }
  
  nonisolated func log (_ closure: @Sendable @escaping (Logger) -> Void) {
    Task {
      await self.logWith(closure)
    }
  }
}

public final actor NetworkExplorer {
  private let browser: NetworkBrowser
  let queue: DispatchQueue = .global()
  private let logger: LoggingActor?
  private let streams = StreamManager()

  public init(bonjourWithType type: String = "_http._tcp", domain: String = "local.", using parameters: NWParameters = .tcp, logger: (@Sendable () -> Logger)?) {
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
      logger?.log{$0.debug("Not service.")}
      return nil
    }
    guard case let .bonjour(txtRecord) = result.metadata else {
      logger?.log{$0.debug("No txt record.")}
      return nil
    }
    var offset = 0
    var port = 80
    var isTLS = false
    if let portValue: Int = txtRecord.getEntry(for: .port) {
      port = portValue
      logger?.log{$0.debug("Found port: \(portValue)")}
      offset += 1
    }
    if let boolValue: Bool = txtRecord.getEntry(for: .tls) {
      isTLS = boolValue
      logger?.log{$0.debug("Found TLS: \(boolValue)")}
      offset += 1
    }
    let scheme = isTLS ? "https" : "http"
    logger?.log{$0.debug("Scheme: \(scheme)")}
    let addressCount = txtRecord.count - offset
    logger?.log{$0.debug("Parsing \(addressCount) Addresses")}
    return (0 ..< addressCount).compactMap { index -> URL? in
      guard let host: String = txtRecord.getEntry(for: .address(index)) else {
        logger?.log{$0.debug("Invalid Address At Index: \(index)")}
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
        logger?.log{$0.debug("Starting Browser.")}

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
            self.logger?.log{$0.debug("Shuting down browser.")}
          }
        }
      }
    }
  }
}
