//
//  NgrokCLIAPIServerFactoryTests.swift
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

import XCTest
@testable import SublimationVapor
import Ngrokit


struct MockDataHandle : DataHandle {
  internal init(_ actualResult: Result<Data?, any Error>) {
    self.actualResult = actualResult
  }
  
  let actualResult : Result<Data?, any Error>
  
  func readToEnd() throws -> Data? {
    return try actualResult.get()
  }
  
  
}

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

class MockNgrokProcess : NgrokProcess {
  internal init(id: UUID) {
    self.id = id
  }
  
  let id : UUID
  func run(onError: @escaping @Sendable (any Error) -> Void) async throws {
    
  }
  
  
}

class MockNgrokCLIAPI : NgrokCLIAPI {
  internal convenience init(id : UUID) {
    self.init(process: MockNgrokProcess(id: id))
  }
  internal init(process: any NgrokProcess) {
    self.process = process
  }
  
  let process : any NgrokProcess
  var httpPorts = [Int]()
  
  func process(forHTTPPort httpPort: Int) -> any Ngrokit.NgrokProcess {
    return process
  }
  
  
}

class MockServerDelegate : NgrokServerDelegate {
  internal init(id: UUID) {
    self.id = id
  }
  
  let id : UUID
  func server(_ server: any SublimationVapor.NgrokServer, updatedTunnel tunnel: Ngrokit.Tunnel) {
    
  }
  
  func server(_ server: any SublimationVapor.NgrokServer, errorDidOccur error: any Error) {
    
  }
  
  
}
class NgrokCLIAPIServerFactoryTests: XCTestCase {
  func testServer() {
    let loggerLabel = UUID().uuidString
    let application = MockServerApplication(
      httpServerConfigurationPort: .random(in: 10...10000),
      logger: .init(label: loggerLabel)
    )
    let delegateID = UUID()
    let processID = UUID()
    let configuration = NgrokCLIAPIConfiguration(serverApplication: application)
    let factory = NgrokCLIAPIServerFactory<MockProcess>(cliAPI: MockNgrokCLIAPI(id: processID))
    let server = factory.server(from: configuration, handler: MockServerDelegate(id: delegateID))
    XCTAssertEqual(
      (server.delegate as? MockServerDelegate)?.id,
      delegateID
    )
    
    XCTAssertEqual(
      server.port,
      application.httpServerConfigurationPort
    )
    
    
    
    XCTAssertEqual(
      (server.process as? MockNgrokProcess)?.id,
      processID
    )
    
    
  }
}
