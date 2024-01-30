import Foundation
import Ngrokit
import NIOCore
import OpenAPIAsyncHTTPClient

public struct NgrokCLIAPIServerFactory: NgrokServerFactory {
  public typealias Configuration = NgrokCLIAPIConfiguration

  private let cliAPI: NgrokCLIAPI
  private let timeout: TimeAmount

  init(
    cliAPI: NgrokCLIAPI = .init(ngrokPath: "/opt/homebrew/bin/ngrok"),
    timeout: TimeAmount = .seconds(1)
  ) {
    self.cliAPI = cliAPI
    self.timeout = timeout
  }

  init(ngrokPath: String, timeout: TimeAmount = .seconds(1)) {
    self.init(cliAPI: .init(ngrokPath: ngrokPath), timeout: timeout)
  }

  public func server(
    from configuration: Configuration,
    handler: any NgrokServerDelegate
  ) -> NgrokCLIAPIServer {
    let client = Ngrok.Client(
      transport: AsyncHTTPClientTransport(configuration: .init(timeout: timeout))
    )

    let process = cliAPI.process(forHTTPPort: configuration.port)
    return .init(
      delegate: handler,
      client: client,
      process: process,
      port: configuration.port,
      logger: configuration.logger
    )
  }
}
