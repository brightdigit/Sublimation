//
//  File.swift
//  
//
//  Created by Leo Dion on 2/2/24.
//

import Foundation
import Ngrokit

//struct MockDataHandle: DataHandle {
//  internal init(_ actualResult: Result<Data?, any Error>) {
//    self.actualResult = actualResult
//  }
//
//  let actualResult: Result<Data?, any Error>
//
//  func readToEnd() throws -> Data? {
//    try actualResult.get()
//  }
//}
//
//final class MockPipe: Pipable {
//  internal init(fileHandleForReading: MockDataHandle) {
//    self.fileHandleForReading = fileHandleForReading
//  }
//
//  let fileHandleForReading: MockDataHandle
//
//  typealias DataHandleType = MockDataHandle
//}

//final class MockProcess: Processable {
//  internal init(executableFilePath: String, scheme: String, port: Int, terminationReason: TerminationReason, standardErrorPipe: MockPipe? = nil, pipeDataResult: Result<Data?, any Error> = .success(nil), runError: (any Error)? = nil) {
//    self.executableFilePath = executableFilePath
//    self.scheme = scheme
//    self.port = port
//    self.standardErrorPipe = standardErrorPipe
//    self.terminationReason = terminationReason
//    self.pipeDataResult = pipeDataResult
//    self.runError = runError
//  }
//
//  internal convenience init(executableFilePath: String, scheme: String, port: Int) {
//    self.init(executableFilePath: executableFilePath, scheme: scheme, port: port, terminationReason: .exit)
//  }
//
//  let executableFilePath: String
//  let scheme: String
//  let port: Int
//  let pipeDataResult: Result<Data?, any Error>
//  let runError: (any Error)?
//  var standardErrorPipe: MockPipe?
//
//  private(set) var isTerminationHandlerSet: Bool = false
//  private(set) var isRunCalled: Bool = false
//
//  nonisolated func createPipe() -> MockPipe {
//    .init(fileHandleForReading: .init(pipeDataResult))
//  }
//
//  typealias PipeType = MockPipe
//
//  let terminationReason: Ngrokit.TerminationReason
//
//  func setTerminationHandler(_: @escaping @Sendable (MockProcess) -> Void) {
//    isTerminationHandlerSet = true
//  }
//
//  func run() throws {
//    isRunCalled = true
//    if let error = runError {
//      throw error
//    }
//  }
//}

package final class MockNgrokProcess: NgrokProcess {
  package  init(id: UUID) {
    self.id = id
  }

  package let id: UUID
  package func run(onError _: @escaping @Sendable (any Error) -> Void) async throws {}
}

package final class MockNgrokCLIAPI: NgrokCLIAPI {
  package  convenience init(id: UUID) {
    self.init(process: MockNgrokProcess(id: id))
  }

  internal init(process: any NgrokProcess) {
    self.process = process
  }

  package let process: any NgrokProcess
  package private(set) var httpPorts = [Int]()

  package func process(forHTTPPort _: Int) -> any Ngrokit.NgrokProcess {
    process
  }
}
