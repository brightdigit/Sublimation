//
//  BonjourDepositor.swift
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
  import Foundation
  #if canImport(os)
    import os
  #else
    import Logging
  #endif
  import Network

  /// `BonjourDepositor` using Bonjour services, to collect URLs advertised by your `Sublimation` server.
public actor BonjourDepositor {
  
    /// Default configuration values for the `BonjourDepositor`.
    public enum Defaults {
      /// The default port number used for the service.
      public static let port = 80
      /// The default TLS setting for the service.
      public static let isSecure = false
      /// The default Bonjour service type.
      public static let bonjourType = "_http._tcp"
      /// The default Bonjour domain.
      public static let bonourDomain = "local."
      
      public static let serviceName = "Sublimation"
    }

    private let browser: NetworkBrowser
    private let browserQueue: DispatchQueue// = .global()
    private let logger: Logger?
  private let streams : StreamManager<UUID, URL> // = StreamManager<UUID, URL>()
//
//    private let defaultPort: Int
//    private let defaultTLS: Bool

    /// The current state of the NWBrowser.
    public var state: NWBrowser.State? {
      get async {
        await self.browser.currentState
      }
    }

    /// An asynchronous stream of URLs discovered by the browser.
    ///
    /// If the stream manager is empty, it starts the browser and begins parsing results.
    public var urls: AsyncStream<URL> {
      get async {
        let browser = browser
        let streams = streams
        if await self.streams.isEmpty {
          logger?.debug("Starting Browser.")

          await browser.start(queue: browserQueue) { result in
            
            switch result {
            case .success(let urls):
              Task {
                await streams.yield(urls, logger: self.logger)
              }
            case .failure(let error):
              self.logger?.error("Unable to parse urls: \(error.localizedDescription)")
            }
          }
        }
        return AsyncStream { continuation in
          Task {
            await streams.append(continuation) {
              await browser.stop()
              self.logger?.debug("Shutting down browser.")
            }
          }
        }
      }
    }


    /// Initializes a `BonjourDepositor` with a browser descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The browser descriptor.
    ///   - parameters: The network parameters.
    ///   - defaultPort: The default port number.
    ///   - defaultTLS: The default TLS setting.
    ///   - logger: An optional logger.
    public init(
      for descriptor: NWBrowser.Descriptor,
      using parameters: NWParameters,
      service serviceName: String,// = "Sublimation",
      defaultPort: Int,// = 8080,
      defaultIsSecure: Bool,// = false,
      logger: Logger?,
      browserQueue: DispatchQueue,
      connectionQueue: @Sendable @escaping () -> DispatchQueue // = { DispatchQueue.global() },
    ) {
      self.init(
        browser: .init(
          for: descriptor,
          using: parameters ,
          service: serviceName,
          defaultPort: defaultPort,
          defaultIsSecure: defaultIsSecure,
          logger: logger,
          queue: connectionQueue
        ),
        browserQueue: browserQueue,
        logger: logger
      )
    }
  
  
  private init(browser: NetworkBrowser, browserQueue: DispatchQueue, logger: Logger?, streams: StreamManager<UUID, URL> = .init()) {
    assert(logger != nil)
    self.browser = browser
    self.browserQueue = browserQueue
    self.logger = logger
    self.streams = streams
  }

  }

  extension BonjourDepositor {
    /// Retrieves the first URL from the asynchronous stream.
    ///
    /// - Returns: The first URL if available, otherwise nil.
    public func first() async -> URL? {
      for await baseURL in await self.urls {
        return baseURL
      }
      return nil
    }
    
    
    /// Initializes a `BonjourDepositor` with a Bonjour service type and domain.
    ///
    /// - Parameters:
    ///   - type: The Bonjour service type.
    ///   - domain: The Bonjour domain.
    ///   - parameters: The network parameters.
    ///   - defaultPort: The default port number.
    ///   - defaultTLS: The default TLS setting.
    ///   - logger: An optional logger.
    public init(
      bonjourWithType type: String = Defaults.bonjourType,
      domain: String = Defaults.bonourDomain,
      using parameters: NWParameters = .tcp,
      service serviceName: String = Defaults.serviceName,
      defaultPort: Int = Defaults.port,
      defaultIsSecure: Bool = Defaults.isSecure,
      logger: Logger? = nil,
      browserQueue: DispatchQueue = .global(),
      connectionQueue: @Sendable @escaping () -> DispatchQueue = {.global()}
    ) {
      self.init(
        for: .bonjour(type: type, domain: domain),
        using: parameters,
        service: serviceName,
        defaultPort: defaultPort, 
        defaultIsSecure: defaultIsSecure,
        logger: logger,
        browserQueue: browserQueue,
        connectionQueue: connectionQueue
      )
    }
  }
#endif
