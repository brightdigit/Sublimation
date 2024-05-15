//
//  StreamManager.swift
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

internal actor StreamManager {
  private var streamContinuations = [UUID: AsyncStream<URL>.Continuation]()

  func yield(_ urls: [URL], logger: LoggingActor?) {
    if streamContinuations.isEmpty {
      logger?.log { $0.debug("Missing Continuations.") }
    }
    for streamContinuation in streamContinuations {
      for url in urls {
        streamContinuation.value.yield(url)
      }
      logger?.log { $0.debug("Yielded to Stream \(streamContinuation.key)") }
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
