
/// A protocol that defines the configuration for an Ngrok server.
///
/// - Note: The associated type `Server` must conform to the `NgrokServer` protocol.
public protocol NgrokServerConfiguration {
  associatedtype Server: NgrokServer
}
