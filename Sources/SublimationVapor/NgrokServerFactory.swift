
public protocol NgrokServerFactory: Sendable {
  associatedtype Configuration: NgrokServerConfiguration

  func server(
    from configuration: Configuration,
    handler: any NgrokServerDelegate
  ) -> Configuration.Server
}
