import Logging
import Vapor

public struct NgrokCLIAPIConfiguration: NgrokServerConfiguration {
  public typealias Server = NgrokCLIAPIServer
  public let port: Int
  public let logger: Logger
}

extension NgrokCLIAPIConfiguration: NgrokVaporConfiguration {
  public init(application: Application) {
    self.init(
      port: application.http.server.configuration.port,
      logger: application.logger
    )
  }
}
