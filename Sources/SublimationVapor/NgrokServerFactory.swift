/**
 A factory protocol for creating Ngrok servers.

 - Note: This protocol is `Sendable`.

 - Requires: A `Configuration` associated type conforming to `NgrokServerConfiguration`.

 - SeeAlso: `NgrokServerDelegate`

 - Returns: A server instance based on the provided configuration.
 */
public protocol NgrokServerFactory: Sendable {
  /// The associated type representing the configuration for the server.
  associatedtype Configuration: NgrokServerConfiguration

  /**
   Creates a server instance based on the provided configuration.

   - Parameters:
     - configuration: The configuration for the server.
     - handler: The delegate object that handles server events.

   - Returns: A server instance based on the provided configuration.
   */
  func server(
    from configuration: Configuration,
    handler: any NgrokServerDelegate
  ) -> Configuration.Server
}
