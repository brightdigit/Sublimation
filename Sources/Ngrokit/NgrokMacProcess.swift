//
//  NgrokMacProcess.swift
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

public actor NgrokMacProcess<ProcessType: Processable>: NgrokProcess {
  private var terminationHandler: (@Sendable (any Error) -> Void)?
  internal let process: ProcessType
  private let pipe: ProcessType.PipeType

  public init(
    ngrokPath: String,
    httpPort: Int,
    processType _: ProcessType.Type
  ) {
    self.init(
      process: .init(
        executableFilePath: ngrokPath,
        scheme: "http",
        port: httpPort
      )
    )
  }

  private init(
    process: ProcessType,
    pipe: ProcessType.PipeType? = nil,
    terminationHandler: (@Sendable (any Error) -> Void)? = nil
  ) {
    self.terminationHandler = terminationHandler
    self.process = process
    if let pipe {
      self.pipe = pipe
    } else {
      let newPipe: ProcessType.PipeType = process.createPipe()
      self.process.standardErrorPipe = newPipe
      self.pipe = newPipe
    }
  }

  @Sendable
  private nonisolated func terminationHandler(forProcess _: any Processable) {
    Task {
      let error: any Error
      do {
        error = try self.pipe.fileHandleForReading.parseNgrokErrorCode()
      } catch let runtimeError as RuntimeError {
        error = runtimeError
      }
      await self.terminationHandler?(error)
    }
  }

  public func run(onError: @Sendable @escaping (any Error) -> Void) async throws {
    process.setTerminationHandler(terminationHandler(forProcess:))
    terminationHandler = onError
    try process.run()
  }
}
