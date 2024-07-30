//
//  TunnelSublimatory.swift
//  Sublimation
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Logging
public import SublimationCore

/// Closure which returns a ``TunnelClient`` from the ``Application``.
public typealias RepositoryClientFactory<Key> =
  (@Sendable @escaping () -> any Application) -> any TunnelClient<Key>

public actor TunnelSublimatory<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
  TunnelServerFactoryType: TunnelServerFactory
>: Sublimatory, TunnelServerDelegate {

  
  public typealias Key = WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key
  public typealias ConnectionErrorType = TunnelServerFactoryType.Configuration.Server.ConnectionErrorType
  private let factory: TunnelServerFactoryType
  private let repoFactory: WritableTunnelRepositoryFactoryType
  private let key: Key
  private let repoClientFactory: RepositoryClientFactory<Key>

  private let tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType
  private let logger: Logger
  private var server: TunnelServerFactoryType.Configuration.Server!

  private nonisolated let isConnectionRefused: @Sendable (ConnectionErrorType) -> Bool
  ///   Initializes the Sublimation lifecycle handler.
  ///
  ///   - Parameters:
  ///     - factory: The factory for creating an Ngrok server.
  ///     - repoFactory: The factory for creating a writable tunnel repository.
  ///     - key: The key for the tunnel repository.
  public init(
    factory: TunnelServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key,
    application: @Sendable @escaping () -> any Application,
    repoClientFactory: @escaping RepositoryClientFactory<Key>,
    isConnectionRefused: @escaping @Sendable (ConnectionErrorType) -> Bool
  ) async {
    let logger = application().logger
    let tunnelRepo = repoFactory.setupClient(
      repoClientFactory(application)
    )
    await self.init(
      factory: factory,
      repoFactory: repoFactory,
      key: key,
      tunnelRepo: tunnelRepo,
      logger: logger,
      repoClientFactory: repoClientFactory,
      isConnectionRefused: isConnectionRefused
    ) {
      factory.server(
        from: TunnelServerFactoryType.Configuration(application: application()),
        handler: $0
      )
    }
  }

  private init(
    factory: TunnelServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: Key,
    tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType,
    logger: Logger,
    repoClientFactory: @escaping RepositoryClientFactory<Key>,
    isConnectionRefused: @escaping @Sendable (ConnectionErrorType) -> Bool,
    server: @escaping @Sendable (TunnelSublimatory<WritableTunnelRepositoryFactoryType, TunnelServerFactoryType>) -> TunnelServerFactoryType.Configuration.Server
  ) async {
    self.factory = factory
    self.repoFactory = repoFactory
    self.key = key
    self.tunnelRepo = tunnelRepo
    self.logger = logger
    self.repoClientFactory = repoClientFactory
    self.isConnectionRefused = isConnectionRefused
    self.server = server(self)
  }

  ///   Saves the tunnel URL to the tunnel repository.
  ///
  ///   - Parameters:
  ///     - tunnel: The tunnel to save.
  ///
  ///   - Note: This method is asynchronous.
  ///
  ///   - SeeAlso: `Tunnel`
  private func saveTunnel(_ tunnel: any Tunnel) async {
    do {
      try await tunnelRepo.saveURL(tunnel.publicURL, withKey: key)
    } catch {
      logger.error(
        "Unable to save url to repository: \(error.localizedDescription)"
      )
      return
    }
//    logger?.notice(
//      "Saved url \(tunnel.publicURL) to repository with key \(key)"
//    )
  }

  ///   Handles an error that occurred during tunnel operation.
  ///
  ///   - Parameters:
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is asynchronous.
  private func onError(_ error: any Error) async {
    logger.error("Error running tunnel: \(error.localizedDescription)")
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
  public nonisolated func server(_: any TunnelServer, updatedTunnel tunnel: any Tunnel) {
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
  public nonisolated func server(_: any TunnelServer, errorDidOccur error: any Error) {
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
//  private func beginFromApplication(_ application: @Sendable @escaping () -> any Application) async {
//    let server = factory.server(
//      from: TunnelServerFactoryType.Configuration(application: application()),
//      handler: self
//    )
//    logger = application().logger
//    tunnelRepo = repoFactory.setupClient(
//      repoClientFactory(application)
//    )
//    self.server = server
//    server.start(isConnectionRefused: isConnectionRefused)
//  }

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
//  public func willBoot(from application: @escaping @Sendable () -> any Application) async {
//    await self.beginFromApplication(application)
//  }
//  
//  func setupForApplication(_ application: @escaping @Sendable () -> any Application) {
//    let server = factory.server(
//      from: TunnelServerFactoryType.Configuration(application: application()),
//      handler: self
//    )
//    logger = application().logger
//    tunnelRepo = repoFactory.setupClient(
//      repoClientFactory(application)
//    )
//    self.server = server
//  }
//  
//  public nonisolated func initialize(for application: @escaping @Sendable  () -> any Application) {
//    Task {
//      await self.setupForApplication(application)
//    }
//  }
//
  func shutdownServer () {
    server.shutdown()
  }
  public nonisolated func shutdown() {
    Task {
      await self.shutdownServer()
    }
  }
  public func run() async throws {
    

    let isConnectionRefused = self.isConnectionRefused
    
    try await server.run(isConnectionRefused: isConnectionRefused)
  }
}
