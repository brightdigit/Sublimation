import Ngrokit
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public final class SublimationLifecycleHandler<
  TunnelRepositoryType: WritableTunnelRepository
>: LifecycleHandler, NgrokServerDelegate {
  public func server(_: NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      do {
        try await self.tunnelRepo.saveURL(tunnel.public_url, withKey: self.key)
      } catch {
        self.logger?.error(
          "Unable to save url to repository: \(error.localizedDescription)"
        )
        return
      }
      self.logger?.notice(
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
  var logger: Logger?

  public func didBoot(_ application: Application) throws {
    logger = application.logger
    server.startTunnelFor(application: application, withDelegate: self)
    tunnelRepo.setupClient(
      VaporTunnelClient(
        client: application.client,
        keyType: TunnelRepositoryType.Key.self
      )
    )
  }

  public func shutdown(_: Application) {}
}

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
