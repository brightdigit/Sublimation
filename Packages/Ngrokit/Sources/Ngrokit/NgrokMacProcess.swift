//
//  NgrokMacProcess.swift
//  Ngrokit
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

/// A class representing a Ngrok process on macOS.
///
/// This class conforms to the `NgrokProcess` protocol.
///
/// - Note: This class is an actor,
/// meaning it can be safely accessed from multiple concurrent tasks.
///
/// - Author: Leo Dion
/// - Version: 2024
/// - Copyright: © BrightDigit
///
/// - SeeAlso: `NgrokProcess`
public actor NgrokMacProcess<ProcessType: Processable>: NgrokProcess {

  private var terminationHandler: (@Sendable (any Error) -> Void)?
  internal let process: ProcessType
  private let pipe: ProcessType.PipeType

  ///   Initializes a new instance of `NgrokMacProcess`.
  ///
  ///   - Parameters:
  ///     - ngrokPath: The path to the Ngrok executable.
  ///     - httpPort: The port to use for the HTTP connection.
  ///     - processType: The type of process to use.
  ///
  ///   - Returns: A new instance of `NgrokMacProcess`.
  public init(ngrokPath: String, httpPort: Int, processType _: ProcessType.Type) {
    self.init(process: .init(executableFilePath: ngrokPath, scheme: "http", port: httpPort))
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
    }
    else {
      let newPipe: ProcessType.PipeType = process.createPipe()
      self.process.standardError = newPipe
      self.pipe = newPipe
    }
  }

  ///   A private method that handles the termination of the process.
  ///
  ///   - Parameters:
  ///     - forProcess: The process that has terminated.
  @Sendable private nonisolated func terminationHandler(forProcess _: any Processable) {
    Task {
      let error: any Error
      do { error = try self.pipe.fileHandleForReading.parseNgrokErrorCode() }
      catch let runtimeError as RuntimeError { error = runtimeError }
      await self.terminationHandler?(error)
    }
  }

  ///   Runs the Ngrok process.
  ///
  ///   - Parameters:
  ///     - onError: A closure that handles any errors that occur during the process.
  ///
  ///   - Throws: An error if the process fails to run.
  public func run(onError: @Sendable @escaping (any Error) -> Void) async throws {
    process.setTerminationHandler(terminationHandler(forProcess:))
    terminationHandler = onError
    try process.run()
  }
  nonisolated public func terminate() { self.process.terminate() }
}
