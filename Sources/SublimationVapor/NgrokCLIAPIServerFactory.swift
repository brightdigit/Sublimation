import Foundation
import Ngrokit
import OpenAPIAsyncHTTPClient

public struct NgrokCLIAPIServerFactory: NgrokServerFactory {
  //let ngrokPath: String
  let cliAPI : NgrokCLIAPI

  public typealias Configuration = NgrokCLIAPIConfiguration
  
  init(cliAPI: NgrokCLIAPI) {
    self.cliAPI = cliAPI
  }
  
  init(ngrokPath: String) {
    self.init(cliAPI: .init(ngrokPath: ngrokPath) )
  }

  public func server(from configuration: Configuration, handler: any NgrokServerDelegate) -> NgrokCLIAPIServer {
    let client = Ngrok.Client(transport: AsyncHTTPClientTransport(configuration: .init(timeout: .seconds(1))))

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
