import Foundation

public struct NgrokCLIAPI: Sendable {
  public let ngrokPath: String

  public init(ngrokPath: String) {
    self.ngrokPath = ngrokPath
  }

  public func process(forHTTPPort httpPort: Int) -> NgrokProcess {
    .init(ngrokPath: ngrokPath, httpPort: httpPort)
  }
}
