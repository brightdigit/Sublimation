import Ngrokit
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public final class SublimationLifecycleHandler<
  TunnelRepositoryType: WritableTunnelRepository
>: LifecycleHandler, NgrokServerDelegate {
  private actor LoggerContainer {
    var logger: Logger?

    func setLogger(_ logger: Logger) {
      self.logger = logger
    }
  }

  public func server(_: NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      do {
        try await self.tunnelRepo.saveURL(tunnel.public_url, withKey: self.key)
      } catch {
        await self.getLogger()?.error(
          "Unable to save url to repository: \(error.localizedDescription)"
        )
        return
      }
      await self.getLogger()?.notice(
        "Saved url \(tunnel.public_url) to repository with key \(self.key)"
      )
    }
  }

  public func server(_: NgrokServer, errorDidOccur _: Error) {}

  public func server(_: NgrokServer, failedWithError _: Error) {}

  public init(
    server: NgrokServer,
    repo: TunnelRepositoryType,
    key: TunnelRepositoryType.Key
  ) {
    self.server = server
    tunnelRepo = repo
    self.key = key
  }

  let server: any NgrokServer
  let tunnelRepo: TunnelRepositoryType
  let key: TunnelRepositoryType.Key
  private func getLogger() async -> Logger? {
    await loggerContainer.logger
  }

  private let loggerContainer = LoggerContainer()

  public func didBoot(_ application: Application) throws {
    Task {
      try! await Task.sleep(for: .seconds(1), tolerance: .seconds(3))
      await self.loggerContainer.setLogger(application.logger)
      await server.startTunnelFor(application: application, withDelegate: self)
      await tunnelRepo.setupClient(
        VaporTunnelClient(
          client: application.client,
          keyType: TunnelRepositoryType.Key.self
        )
      )
    }
    // logger = application.logger
  }

  public func shutdown(_: Application) {}
}

#if os(macOS)
  extension SublimationLifecycleHandler {
    public convenience init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key
    ) where TunnelRepositoryType == KVdbTunnelRepository<Key> {
      self.init(
        server: NgrokCLIAPIServer(ngrokPath: ngrokPath),
        repo: .init(bucketName: bucketName),
        key: key
      )
    }
  }
#endif
