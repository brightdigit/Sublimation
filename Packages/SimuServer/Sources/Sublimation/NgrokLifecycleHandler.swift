import Ngrokit
import Vapor
public class NgrokLifecycleHandler<TunnelRepositoryType : WritableTunnelRepository> : LifecycleHandler, NgrokServerDelegate {
  public func server(_ server: NgrokServer, updatedTunnel tunnel: Ngrokit.NgrokTunnel) {
    Task {
      do {
        try await self.tunnelRepo.saveURL(tunnel.public_url, withKey: self.key)
      } catch {
        self.logger?.error("Unable to save url to repository: \(error.localizedDescription)")
      }
    }
  }
  
  public func server(_ server: NgrokServer, errorDidOccur error: Error) {
    
  }
  
  public func server(_ server: NgrokServer, failedWithError error: Error) {
    
  }
  

  public init(server: NgrokServer, repo: TunnelRepositoryType, key: TunnelRepositoryType.Key) {
    self.server = server
    self.tunnelRepo = repo
    self.key = key
  }
  
  let server : NgrokServer
  let tunnelRepo : TunnelRepositoryType
  let key: TunnelRepositoryType.Key
  var logger : Logger?
  
  public func didBoot(_ application: Application) throws {
//
//    server.setupClient(application.client)
//    server.setupLogger(application.logger)
//    let port = application.http.server.shared.configuration.port
    self.logger = application.logger
    self.server.startTunnelFor(application: application, withDelegate: self)
    self.tunnelRepo.setupClient(
      VaporTunnelClient(
        client:  application.client,
        keyType: TunnelRepositoryType.Key.self
      ).eraseToAnyClient()
    )
//    Task {
//      do {
//        let tunnel = try await self.server.startHttp(port: port)
//        application.logger.notice("Tunnel started on \(tunnel.public_url)")
//      } catch {
//        dump(error)
//      }
//    }
    
  }
  
  public func shutdown(_ application: Application) {
    
  }
}

public extension NgrokLifecycleHandler {
  convenience init<Key>(bucketName: String, key: Key) where TunnelRepositoryType == KeyDBTunnelRepository<Key> {

    self.init(server: NgrokCLIAPIServer(), repo: .init(bucketName: bucketName), key: key)
  }
}

