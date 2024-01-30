import Foundation
import Ngrokit
import NIOCore
import OpenAPIAsyncHTTPClient

public struct NgrokCLIAPIServerFactory: NgrokServerFactory {
  let cliAPI: NgrokCLIAPI
  let timeout: TimeAmount

  public typealias Configuration = NgrokCLIAPIConfiguration

  init(
    cliAPI: NgrokCLIAPI = .init(ngrokPath: "/opt/homebrew/bin/ngrok"),
    timeout: TimeAmount = .seconds(1)
  ) {
    self.cliAPI = cliAPI
    self.timeout = timeout
  }

  init(ngrokPath: String) {
    self.init(cliAPI: .init(ngrokPath: ngrokPath))
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
