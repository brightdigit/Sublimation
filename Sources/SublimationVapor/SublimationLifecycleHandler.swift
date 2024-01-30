import AsyncHTTPClient
import Ngrokit
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public final class SublimationLifecycleHandler<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
  NgrokServerFactoryType: NgrokServerFactory
>: LifecycleHandler, NgrokServerDelegate where NgrokServerFactoryType.Configuration: NgrokVaporConfiguration {
  init(factory: NgrokServerFactoryType, repoFactory: WritableTunnelRepositoryFactoryType, key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key, tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType? = nil, logger: Logger? = nil, server: (any NgrokServer)? = nil) {
    self.factory = factory
    self.repoFactory = repoFactory
    self.key = key
    self.tunnelRepo = tunnelRepo
    self.logger = logger
    self.server = server
  }

  public func server(_: any NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      do {
        try await self.tunnelRepo?.saveURL(tunnel.publicURL, withKey: self.key)
      } catch {
        self.logger?.error(
          "Unable to save url to repository: \(error.localizedDescription)"
        )
        return
      }
      self.logger?.notice(
        "Saved url \(tunnel.publicURL) to repository with key \(self.key)"
      )
    }
  }

  public func server(_: any NgrokServer, errorDidOccur _: any Error) {
    #warning("How to handle this")
  }

  public func server(_: any NgrokServer, failedWithError _: any Error) {
    #warning("How to handle this")
  }

  let factory: NgrokServerFactoryType
  let repoFactory: WritableTunnelRepositoryFactoryType
  let key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key

  var tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?
  var logger: Logger?
  var server: (any NgrokServer)?

  public func willBoot(_ application: Application) throws {
    logger = application.logger
    tunnelRepo = repoFactory.setupClient(
      VaporTunnelClient(client: application.client,
                        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self)
    )
    let server = factory.server(
      from: NgrokServerFactoryType.Configuration(application: application),
      handler: self
    )
    self.server = server
    server.start()
  }

  public func shutdown(_: Application) {}
}

#if os(macOS)
  extension SublimationLifecycleHandler {
    public convenience init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key
    ) where WritableTunnelRepositoryFactoryType == KVdbTunnelRepositoryFactory<Key>,
      NgrokServerFactoryType == NgrokCLIAPIServerFactory,
      WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key == Key {
      self.init(
        factory: NgrokCLIAPIServerFactory(ngrokPath: ngrokPath),
        repoFactory: KVdbTunnelRepositoryFactory(bucketName: bucketName),
        key: key
      )
    }
  }
#endif
