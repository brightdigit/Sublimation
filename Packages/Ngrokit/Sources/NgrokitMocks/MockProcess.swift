//
//  MockProcess.swift
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

public import Foundation
public import Ngrokit

public final class MockProcess: Processable {
  public func terminate() {}
  public typealias PipeType = MockPipe

  package let executableFilePath: String
  package let scheme: String
  package let port: Int
  package let pipeDataResult: Result<Data?, any Error>
  package let runError: (any Error)?
  public let terminationReason: Ngrokit.TerminationReason
  public nonisolated(unsafe) var standardError: MockPipe?

  package private(set) nonisolated(unsafe) var isTerminationHandlerSet = false
  package private(set) nonisolated(unsafe) var isRunCalled = false

  internal init(
    executableFilePath: String,
    scheme: String,
    port: Int,
    terminationReason: TerminationReason,
    standardError: MockPipe? = nil,
    pipeDataResult: Result<Data?, any Error> = .success(nil),
    runError: (any Error)? = nil
  ) {
    self.executableFilePath = executableFilePath
    self.scheme = scheme
    self.port = port
    self.standardError = standardError
    self.terminationReason = terminationReason
    self.pipeDataResult = pipeDataResult
    self.runError = runError
  }

  public convenience init(executableFilePath: String, scheme: String, port: Int) {
    self.init(
      executableFilePath: executableFilePath,
      scheme: scheme,
      port: port,
      terminationReason: .exit
    )
  }

  public nonisolated func createPipe() -> MockPipe {
    .init(fileHandleForReading: .init(pipeDataResult))
  }

  public func setTerminationHandler(_: @escaping @Sendable (MockProcess) -> Void) {
    isTerminationHandlerSet = true
  }

  public func run() throws {
    isRunCalled = true
    if let error = runError { throw error }
  }
}
