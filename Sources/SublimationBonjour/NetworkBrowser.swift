//
//  NetworkBrowser.swift
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
  import Network
import os.log

extension ServerConfiguration {

  func isValidIPv6Address(_ ip: String) -> Bool {
      var sin6 = sockaddr_in6()
      return ip.withCString { cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) } == 1
  }

  func formatIPv6ForURL(_ ip: String) -> String {
      if isValidIPv6Address(ip) {
          return "[\(ip)]"
      } else {
          return ip
      }
  }

  func urls (defaultPort: Int, defaultIsSecure: Bool, logger: Logger?) -> [URL] {
    let portInt32 = self.hasPort ? self.port : nil
    let port = portInt32.map(Int.init) ?? defaultPort
    let isSecure = self.hasIsSecure ? self.isSecure : defaultIsSecure
    let scheme = isSecure ? "https" : "http"
    return self.hosts.compactMap { host in
      guard let url = URL(scheme: scheme, host: formatIPv6ForURL(host), port: port) else {
        logger?.warning("Invalid URL with Host: \(host)")
        return nil
      }
      return url
    }
  }
}

  internal actor NetworkBrowser {
    internal private(set) var currentState: NWBrowser.State?
    private let browser: NWBrowser
    private var withURLs : (@Sendable (Result<[URL], any Error>) -> Void)!
    
    internal init(
      for descriptor: NWBrowser.Descriptor,
      using parameters: NWParameters = .tcp,
      service serviceName: String,// = "Sublimation",
      defaultPort: Int,// = 8080,
      defaultIsSecure: Bool,// = false,
      logger: Logger?,
      queue: @Sendable @escaping () -> DispatchQueue
    ) {
      let browser = NWBrowser(for: descriptor, using: parameters)
      self.browser = browser
      browser.stateUpdateHandler = { state in
        Task {
          await self.onUpdateState(state)
        }
      }
      browser.browseResultsChangedHandler = { newResults, _ in
        Task {
          let endPoints: [NWEndpoint] = newResults.compactMap { result in
            guard case let .service(service) = result.endpoint else {
              return nil
            }
            guard service.name == serviceName else {
              return nil
            }
            dump(result.endpoint)
            return result.endpoint
          }
          print(endPoints.count)
          for endpoint in endPoints {
            print(endpoint)
            let withURLs = await self.withURLs
            let connection = NWConnection(to: endpoint, using: .tcp)
            connection.start(queue: .global())
            let result : Result<[URL], any Error>
            do {
              let urls: [URL] = try await withCheckedThrowingContinuation { continuation in
                
                connection.receiveMessage { content, context, isComplete, error in
                  print("Received Message")
                  dump(context?.identifier)
                  dump(isComplete)
                  if let error {
                    dump(error)
                    continuation.resume(throwing: error)
                  } else if let content {
                    let configuration : ServerConfiguration
                    do {
                      configuration = try ServerConfiguration(serializedData: content)
                    } catch {
                      continuation.resume(throwing: error)
                      return
                    }
                    let urls = configuration.urls(defaultPort: defaultPort, defaultIsSecure: defaultIsSecure, logger: logger)
                    continuation.resume(returning: urls)
                  } else {
                    print("no return value")
                    continuation.resume(returning: [])
                  }
                }
              }
              result = .success(urls)
            } catch {
              result = .failure(error)
            }
            dump(result)
            withURLs!(result)
          }
        }
        

//        connection.start(queue: .global())
//        connection.receiveMessage { content, _, _, error in
//          guard let content else {
//            return
//          }
//          do {
//            let configuration = try ServerConfiguration(serializedData: content)
//            dump(configuration)
//          } catch {
//            dump(error)
//          }
//
//        }
      }
    }

//    private init(browser: NWBrowser) {
//      self.browser = browser
//    }

    internal func start(
      queue: DispatchQueue,
      _ withURLs: @Sendable @escaping (Result<[URL], any Error>) -> Void
    ) {
      self.withURLs = withURLs
      browser.start(queue: queue)
      // parseResult = parser
    }

    private func onUpdateState(_ state: NWBrowser.State) {
      currentState = state
    }

//    private func onResultsChanged(
//      to _: Set<NWBrowser.Result>,
//      withChanges changes: Set<NWBrowser.Result.Change>
//    ) {
//      guard let parseResult else {
//        return
//      }
//      for change in changes {
//        if let result = change.newMetadataChange {
//          parseResult(result)
//        }
//      }
//    }

    internal func stop() {
      browser.stateUpdateHandler = nil
      browser.cancel()
    }
  }
#endif
