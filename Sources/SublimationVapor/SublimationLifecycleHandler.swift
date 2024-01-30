import AsyncHTTPClient
import Ngrokit
import OpenAPIAsyncHTTPClient
import OpenAPIRuntime
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public actor SublimationLifecycleHandler<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
  NgrokServerFactoryType: NgrokServerFactory
>: LifecycleHandler, NgrokServerDelegate
  where NgrokServerFactoryType.Configuration: NgrokVaporConfiguration {
  private let factory: NgrokServerFactoryType
  private let repoFactory: WritableTunnelRepositoryFactoryType
  private let key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key

  private var tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?
  private var logger: Logger?
  private var server: (any NgrokServer)?

  public init(
    factory: NgrokServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key
  ) {
    self.init(
      factory: factory,
      repoFactory: repoFactory,
      key: key,
      tunnelRepo: nil,
      logger: nil,
      server: nil
    )
  }

  private init(
    factory: NgrokServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key,
    tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?,
    logger: Logger?,
    server: (any NgrokServer)?
  ) {
    self.factory = factory
    self.repoFactory = repoFactory
    self.key = key
    self.tunnelRepo = tunnelRepo
    self.logger = logger
    self.server = server
  }

  private func saveTunnel(_ tunnel: Tunnel) async {
    do {
      try await tunnelRepo?.saveURL(tunnel.publicURL, withKey: key)
    } catch {
      logger?.error(
        "Unable to save url to repository: \(error.localizedDescription)"
      )
      return
    }
    logger?.notice(
      "Saved url \(tunnel.publicURL) to repository with key \(key)"
    )
  }

  private func onError(_: any Error) async {}

  public nonisolated func server(_: any NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      await self.saveTunnel(tunnel)
    }
  }

  public nonisolated func server(_: any NgrokServer, errorDidOccur error: any Error) {
    Task {
      await self.onError(error)
    }
  }

  private func beginFromApplication(_ application: Application) async {
    let server = factory.server(
      from: NgrokServerFactoryType.Configuration(application: application),
      handler: self
    )
    logger = application.logger
    tunnelRepo = repoFactory.setupClient(
      VaporTunnelClient(
        client: application.client,

        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self
      )
    )
    self.server = server
    server.start()
  }

  public nonisolated func willBoot(_ application: Application) throws {
    Task {
      await self.beginFromApplication(application)
    }
  }

  public nonisolated func shutdown(_: Application) {}
}

#if os(macOS)
  extension SublimationLifecycleHandler {
    public init<Key>(
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
