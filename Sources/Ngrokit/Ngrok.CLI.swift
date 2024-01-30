import Foundation
import NgrokOpenAPIClient
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension FileHandle {
  // swiftlint:disable:next force_try
  static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
  func parseNgrokErrorCode() throws -> Int? {
    guard let data = try readToEnd() else {
      return nil
    }

    guard let text = String(data: data, encoding: .utf8) else {
      throw RuntimeError.invalidErrorData(data)
    }

    guard let match = FileHandle.errorRegex.firstMatch(
      in: text,
      range: .init(location: 0, length: text.count)
    ), match.numberOfRanges > 0 else {
      return nil
    }

    guard let range = Range(match.range(at: 1), in: text) else {
      return nil
    }
    return Int(text[range])
  }
}

extension Ngrok {
  #if os(macOS)
    public struct CLI: Sendable {
      public init(executableURL: URL) {
        self.executableURL = executableURL
      }

      let executableURL: URL

      private func processTerminated(_: Process) {}

      public func http(port: Int, terminationHandler: @Sendable @escaping (any Error) -> Void) throws -> Process {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = executableURL
        process.standardError = pipe
        process.arguments = ["http", port.description]
        process.terminationHandler = { _ in
          let errorCode: Int?

          do {
            errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
          } catch {
            terminationHandler(error)
            return
          }
          terminationHandler(RuntimeError.earlyTermination(process.terminationReason, errorCode))
        }
        try process.run()
        return process
//        return try await withCheckedThrowingContinuation { continuation in
//          let semaphoreResult = semaphore.wait(timeout: timeout)
//          guard semaphoreResult == .success else {
//            process.terminationHandler = nil
//            continuation.resume(returning: process)
//            return
//          }
//          let errorCode: Int?
//
//          do {
//            errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
//          } catch {
//            continuation.resume(with: .failure(error))
//            return
//          }
//          continuation.resume(with:
//              .failure(
//                RuntimeError.earlyTermination(process.terminationReason, errorCode))
//          )
//        }
      }

      public func http(port: Int, timeout: DispatchTime) async throws -> Process {
        let process = Process()
        let pipe = Pipe()
        let semaphore = DispatchSemaphore(value: 0)
        process.executableURL = executableURL
        process.arguments = ["http", port.description]
        process.standardError = pipe
        process.terminationHandler = { _ in
          semaphore.signal()
        }
        try process.run()
        return try await withCheckedThrowingContinuation { continuation in
          let semaphoreResult = semaphore.wait(timeout: timeout)
          guard semaphoreResult == .success else {
            process.terminationHandler = nil
            continuation.resume(returning: process)
            return
          }
          let errorCode: Int?

          do {
            errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
          } catch {
            continuation.resume(with: .failure(error))
            return
          }
          continuation.resume(with:
            .failure(
              RuntimeError.earlyTermination(process.terminationReason, errorCode))
          )
        }
      }
    }
  #endif
}
