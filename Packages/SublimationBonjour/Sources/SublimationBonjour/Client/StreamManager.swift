//
//  StreamManager.swift
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

internal import Foundation

#if canImport(os)
  internal import os
#elseif canImport(Logging)
  internal import Logging
#endif

internal actor StreamManager<Key: Hashable & Sendable, Value: Sendable> {
  private var streamContinuations: [Key: AsyncStream<Value>.Continuation] = [:]

  private var newID: @Sendable () -> Key

  internal var isEmpty: Bool { streamContinuations.isEmpty }

  internal init(newID: @escaping @Sendable () -> Key) { self.newID = newID }

  internal func yield(_ urls: [Value], logger: Logger?) {
    if streamContinuations.isEmpty { logger?.debug("Missing Continuations.") }
    for streamContinuation in streamContinuations {
      for url in urls { streamContinuation.value.yield(url) }
    }
  }

  private func onTerminationOf(_ id: Key) -> Bool {
    streamContinuations.removeValue(forKey: id)
    return streamContinuations.isEmpty
  }

  internal func append(
    _ continuation: AsyncStream<Value>.Continuation,
    onCancel: @Sendable @escaping () async -> Void
  ) {
    let id = newID()
    streamContinuations[id] = continuation
    continuation.onTermination = { _ in
      Task {
        let shouldCancel = await self.onTerminationOf(id)
        if shouldCancel { await onCancel() }
      }
    }
  }
}

extension StreamManager { internal init() where Key == UUID { self.init { UUID() } } }
