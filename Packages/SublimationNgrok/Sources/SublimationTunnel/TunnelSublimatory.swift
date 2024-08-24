//
//  TunnelSublimatory.swift
//  SublimationNgrok
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
public typealias RepositoryClientFactory<Key> = (@Sendable @escaping () -> any Application) ->
  any TunnelClient<Key>

/// A `Sublimatory` which uses creates and saves a``Tunnel``.
public actor TunnelSublimatory<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
  TunnelServerFactoryType: TunnelServerFactory
>: Sublimatory, TunnelServerDelegate {

  /// `Key type
  public typealias Key = WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key
  /// Type of Error which can be thrown by the Network Client.
  public typealias ConnectionErrorType = TunnelServerFactoryType.Configuration.Server
    .ConnectionErrorType
  private let factory: TunnelServerFactoryType
  private let repoFactory: WritableTunnelRepositoryFactoryType
  private let key: Key
  private let repoClientFactory: RepositoryClientFactory<Key>

  private let tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType
  private let logger: Logger
  // swift-format-ignore: NeverUseImplicitlyUnwrappedOptionals
  private var server: TunnelServerFactoryType.Configuration.Server!

  private nonisolated let isConnectionRefused: @Sendable (ConnectionErrorType) -> Bool
  /// Initializes the Sublimation lifecycle handler.
  ///
  /// - Parameters:
  ///   - factory: The factory for creating an Ngrok server.
  ///   - repoFactory: The factory for creating a writable tunnel repository.
  ///   - key: The key for the tunnel repository.
  ///   - application: Returns the Application to use.
  ///   - repoClientFactory: Takes an Application and returns a client for the tunnel.
  ///   - isConnectionRefused: Whether the error is just connection refused because it's not active.
  public init(
    factory: TunnelServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key,
    application: @Sendable @escaping () -> any Application,
    repoClientFactory: @escaping RepositoryClientFactory<Key>,
    isConnectionRefused: @escaping @Sendable (ConnectionErrorType) -> Bool
  ) async {
    let logger = application().logger
    let tunnelRepo = repoFactory.setupClient(repoClientFactory(application))
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
    server: @escaping @Sendable (
      TunnelSublimatory<WritableTunnelRepositoryFactoryType, TunnelServerFactoryType>
    ) -> TunnelServerFactoryType.Configuration.Server
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
  ///   - Parameter tunnel: The tunnel to save.
  ///
  ///   - Note: This method is asynchronous.
  ///
  ///   - SeeAlso: `Tunnel`
  private func saveTunnel(_ tunnel: any Tunnel) async {
    do { try await tunnelRepo.saveURL(tunnel.publicURL, withKey: key) }
    catch {
      logger.error("Unable to save url to repository: \(error.localizedDescription)")
      return
    }
    //    logger?.notice(
    //      "Saved url \(tunnel.publicURL) to repository with key \(key)"
    //    )
  }

  ///   Handles an error that occurred during tunnel operation.
  ///
  ///   - Parameter error: The error that occurred.
  ///
  ///   - Note: This method is asynchronous.
  private func onError(_ error: any Error) async {
    logger.error("Error running tunnel: \(error.localizedDescription)")
  }

  ///   Called when an Ngrok server updates a tunnel.
  ///
  ///   - Parameters:
  ///     - _: The Ngrok server.
  ///     - tunnel: The updated tunnel.
  ///
  ///   - Note: This method is nonisolated.
  ///
  ///   - SeeAlso: `NgrokServer`
  ///   - SeeAlso: `Tunnel`
  public nonisolated func server(_: any TunnelServer, updatedTunnel tunnel: any Tunnel) {
    Task { await self.saveTunnel(tunnel) }
  }

  ///   Called when an error occurs in the Ngrok server.
  ///
  ///   - Parameters:
  ///     - _: The Ngrok server.
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is nonisolated.
  ///
  ///   - SeeAlso: `NgrokServer`
  public nonisolated func server(_: any TunnelServer, errorDidOccur error: any Error) {
    Task { await self.onError(error) }
  }
  private func shutdownServer() { server.shutdown() }
  /// Shutdown any active services.
  public nonisolated func shutdown() { Task { await self.shutdownServer() } }
  /// Runs the Sublimatory service.
  /// -  Note: This method contains long running work, returning from it is seen as a failure.
  public func run() async throws {

    let isConnectionRefused = self.isConnectionRefused
    try await server.run(isConnectionRefused: isConnectionRefused)
  }
}
