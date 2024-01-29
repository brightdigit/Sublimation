import Foundation
import NgrokOpenAPIClient
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Ngrok {
  #if os(macOS)
    public struct CLI: Sendable {
      public init(executableURL: URL) {
        self.executableURL = executableURL
      }

      let executableURL: URL

      private func processTerminated(_: Process) {}

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
