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
    }
  #endif
}
