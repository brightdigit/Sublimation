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

internal actor NetworkBrowser {
  internal private(set) var currentState: NWBrowser.State?
  private let browser: NWBrowser
  private var parseResult: ((NWBrowser.Result) -> Void)?

  internal init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters) {
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

  internal func start(
    queue: DispatchQueue,
    parser: @Sendable @escaping (NWBrowser.Result) -> Void
  ) {
    browser.start(queue: queue)
    parseResult = parser
  }

  private func onUpdateState(_ state: NWBrowser.State) {
    currentState = state
  }

  private func onResultsChanged(
    to _: Set<NWBrowser.Result>,
    withChanges changes: Set<NWBrowser.Result.Change>
  ) {
    guard let parseResult else {
      return
    }
    for change in changes {
      if let result = change.newMetadataChange {
        parseResult(result)
      }
    }
  }

  internal func stop() {
    browser.stateUpdateHandler = nil
    browser.cancel()
  }
}
#endif
