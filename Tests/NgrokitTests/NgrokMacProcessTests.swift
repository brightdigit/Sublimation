//
//  NgrokMacProcessTests.swift
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
@testable import Ngrokit
import XCTest

final class MockPipe : Pipable {
  internal init(fileHandleForReading: MockDataHandle) {
    self.fileHandleForReading = fileHandleForReading
  }
  
  let fileHandleForReading: MockDataHandle
  
  typealias DataHandleType = MockDataHandle
  
  
}
final class MockProcess: Processable {
  internal init(executableFilePath: String, scheme: String, port: Int, terminationReason: TerminationReason, standardErrorPipe: MockPipe? = nil, pipeDataResult : Result<Data?, any Error> = .success(nil), runError: (any Error)? = nil) {
    self.executableFilePath = executableFilePath
    self.scheme = scheme
    self.port = port
    self.standardErrorPipe = standardErrorPipe
    self.terminationReason = terminationReason
    self.pipeDataResult = pipeDataResult
    self.runError = runError
  }
  
  
  internal convenience init(executableFilePath: String, scheme: String, port: Int) {
    self.init(executableFilePath: executableFilePath, scheme: scheme, port: port, terminationReason: .exit)
  }
  
  let executableFilePath: String
  let scheme : String
  let port: Int
  let pipeDataResult : Result<Data?, any Error>
  let runError : (any Error)?
  var standardErrorPipe: MockPipe?
  
  private (set) var isTerminationHandlerSet : Bool = false
  private (set) var isRunCalled : Bool = false
  
  nonisolated func createPipe() -> MockPipe {
    return .init(fileHandleForReading: .init(self.pipeDataResult))
  }
  
  typealias PipeType = MockPipe
  
  let terminationReason: Ngrokit.TerminationReason
  
  
  func setTerminationHandler(_ closure: @escaping @Sendable (MockProcess) -> Void) {
    self.isTerminationHandlerSet = true
  }
  
  func run() throws {
    self.isRunCalled = true
    if let error = runError {
      throw error
    }
  }
  

  
  
}

class NgrokMacProcessTests: XCTestCase {
  func testInit() async {
    let ngrokPath = UUID().uuidString
    let httpPort = Int.random(in: 10...10000)
    let process = NgrokMacProcess(
      ngrokPath: ngrokPath,
      httpPort: httpPort,
      processType: MockProcess.self
    )
    let actualProcess = await process.process
    XCTAssertEqual(actualProcess.executableFilePath, ngrokPath)
    XCTAssertEqual(actualProcess.port, httpPort)
    XCTAssertEqual(actualProcess.scheme, "http")
  }

  func testRunOnError() async throws {
    let ngrokPath = UUID().uuidString
    let httpPort = Int.random(in: 10...10000)
    let process = NgrokMacProcess(
      ngrokPath: ngrokPath,
      httpPort: httpPort,
      processType: MockProcess.self
    )
    try await process.run { _ in }
    
    let actualProcess = await process.process
    XCTAssertTrue(actualProcess.isRunCalled)
    XCTAssertTrue(actualProcess.isTerminationHandlerSet)
  }
}
