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
  import Network
import Foundation

  internal actor NetworkBrowser {
    internal private(set) var currentState: NWBrowser.State?
    private let browser: NWBrowser
    private var parseResult: ((NWBrowser.Result) -> Void)?

    private let serviceName = "Sublimation"
    private let parameters : NWParameters = .tcp
    private let dispatchQueue : () -> DispatchQueue
    internal init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters) {
      let browser = NWBrowser(for: descriptor, using: parameters)
      self.init(browser: browser)
      browser.stateUpdateHandler = { state in
        Task {
          await self.onUpdateState(state)
        }
      }
      browser.browseResultsChangedHandler = { newResults, changes in
        let endPoints : [NWEndpoint] = newResults.compactMap { result in
          guard case let .service(service) = result.endpoint else {
            return nil
          }
          guard service.name == self.serviceName else {
            return nil
          }
          dump(result.endpoint)
          return result.endpoint
        }
        let parameters = self.parameters
        for endpoint in endPoints {
          
          Task {
            let connection = NWConnection(to: endpoint, using: parameters)
            connection.start(queue: self.dispatchQueue())
            let urls : [URL] = try await withCheckedThrowingContinuation { continuation in
              connection.receiveMessage { content, contentContext, isComplete, error in
                if let error {
                  continuation.resume(throwing: error)
                }
              }
            }
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

    private init(browser: NWBrowser) {
      self.browser = browser
    }

    internal func start(
      queue: DispatchQueue
    ) {
      browser.start(queue: queue)
      //parseResult = parser
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
