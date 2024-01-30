import Ngrokit
import Foundation
import OpenAPIAsyncHTTPClient

public struct NgrokCLIAPIServerFactory: NgrokServerFactory {
  let ngrokPath: String

  public typealias Configuration = NgrokCLIAPIConfiguration

  public func server(from configuration: Configuration, handler: any NgrokServerDelegate) -> NgrokCLIAPIServer {
    let client = Ngrok.Client(transport: AsyncHTTPClientTransport(configuration: .init(timeout: .seconds(1))))

    let process = Process()
    process.executableURL = .init(filePath: ngrokPath)
    process.arguments = ["http", configuration.port.description]
    return .init(
      delegate: handler,
      client: client,
      process: process,
      port: configuration.port,
      logger: configuration.logger
    )
  }
}
