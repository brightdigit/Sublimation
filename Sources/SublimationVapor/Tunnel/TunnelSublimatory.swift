//
//  File.swift
//  
//
//  Created by Leo Dion on 5/15/24.
//

import Foundation
import Sublimation
import Vapor
import Ngrokit

public actor TunnelSublimatory<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
  NgrokServerFactoryType: NgrokServerFactory
> : Sublimatory, NgrokServerDelegate where NgrokServerFactoryType.Configuration: NgrokVaporConfiguration {
  private let factory: NgrokServerFactoryType
  private let repoFactory: WritableTunnelRepositoryFactoryType
  private let key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key

  private var tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?
  private var logger: Logger?
  private var server: (any NgrokServer)?

  ///   Initializes the Sublimation lifecycle handler.
  ///
  ///   - Parameters:
  ///     - factory: The factory for creating an Ngrok server.
  ///     - repoFactory: The factory for creating a writable tunnel repository.
  ///     - key: The key for the tunnel repository.
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

  ///   Saves the tunnel URL to the tunnel repository.
  ///
  ///   - Parameters:
  ///     - tunnel: The tunnel to save.
  ///
  ///   - Note: This method is asynchronous.
  ///
  ///   - SeeAlso: `Tunnel`
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

  ///   Handles an error that occurred during tunnel operation.
  ///
  ///   - Parameters:
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is asynchronous.
  private func onError(_ error: any Error) async {
    logger?.error("Error running tunnel: \(error.localizedDescription)")
  }

  ///   Called when an Ngrok server updates a tunnel.
  ///
  ///   - Parameters:
  ///     - server: The Ngrok server.
  ///     - tunnel: The updated tunnel.
  ///
  ///   - Note: This method is nonisolated.
  ///
  ///   - SeeAlso: `NgrokServer`
  ///   - SeeAlso: `Tunnel`
  public nonisolated func server(_: any NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      await self.saveTunnel(tunnel)
    }
  }

  ///   Called when an error occurs in the Ngrok server.
  ///
  ///   - Parameters:
  ///     - server: The Ngrok server.
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is nonisolated.
  ///
  ///   - SeeAlso: `NgrokServer`
  public nonisolated func server(_: any NgrokServer, errorDidOccur error: any Error) {
    Task {
      await self.onError(error)
    }
  }

  ///   Begins the Sublimation application from the given application.
  ///
  ///   - Parameters:
  ///     - application: The Vapor application.
  ///
  ///   - Note: This method is private and asynchronous.
  ///
  ///   - SeeAlso: `Application`
  private func beginFromApplication(_ application: @Sendable @escaping () -> any Application) async {
    let server = factory.server(
      from: NgrokServerFactoryType.Configuration(application: application()),
      handler: self
    )
    logger = application().logger
    tunnelRepo = repoFactory.setupClient(
      VaporTunnelClient(
        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self,
        get: {
          try await application().get(from: $0)
        }, post: {
          try await application().post(to: $0, body: $1)
        })
//      VaporTunnelClient(
//        client: application.client,
//        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self
//      )
    )
    self.server = server
    server.start()
  }
  
  ///   Called when the application is about to boot.
  ///
  ///   - Parameters:
  ///     - application: The Vapor application.
  ///
  ///   - Throws: An error if the application fails to begin.
  ///
  ///   - Note: This method is nonisolated.
  ///
  ///   - SeeAlso: `Application`
  public func willBoot(from application: @escaping @Sendable () -> any Application) async {
    
    await self.beginFromApplication(application)
    
  }
}
#if os(macOS)
  extension TunnelSublimatory {
    ///     Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    ///     - Parameters:
    ///       - ngrokPath: The path to the Ngrok executable.
    ///       - bucketName: The name of the bucket for the tunnel repository.
    ///       - key: The key for the tunnel repository.
    ///
    ///     - Note: This initializer is only available on macOS.
    ///
    ///     - SeeAlso: `KVdbTunnelRepositoryFactory`
    ///     - SeeAlso: `NgrokCLIAPIServerFactory`
    public init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key
    ) where WritableTunnelRepositoryFactoryType == KVdbTunnelRepositoryFactory<Key>,
      NgrokServerFactoryType == NgrokCLIAPIServerFactory<ProcessableProcess>,
      WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key == Key {
      self.init(
        factory: NgrokCLIAPIServerFactory(ngrokPath: ngrokPath),
        repoFactory: KVdbTunnelRepositoryFactory(bucketName: bucketName),
        key: key
      )
    }
  }
#endif
