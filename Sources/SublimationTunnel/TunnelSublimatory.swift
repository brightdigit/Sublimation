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
import SublimationCore

public actor TunnelSublimatory<
  WritableTunnelRepositoryFactoryType: WritableTunnelRepositoryFactory,
    TunnelServerFactoryType: TunnelServerFactory
>: Sublimatory, TunnelServerDelegate {
  private let factory:   TunnelServerFactoryType
  private let repoFactory: WritableTunnelRepositoryFactoryType
  private let key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key
  private let repoClientFactory : (@Sendable @escaping () -> any Application) -> any KVdbTunnelClient<WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key>

  private var tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?
  private var logger: Logger?
  private var server: (any TunnelServer)?
  
 private let isConnectionRefused:  (TunnelServerFactoryType.Configuration.Server.ConnectionErrorType) -> Bool
  ///   Initializes the Sublimation lifecycle handler.
  ///
  ///   - Parameters:
  ///     - factory: The factory for creating an Ngrok server.
  ///     - repoFactory: The factory for creating a writable tunnel repository.
  ///     - key: The key for the tunnel repository.
  public init(
    factory:   TunnelServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key,
    repoClientFactory : @escaping (@Sendable @escaping () -> any Application) -> any KVdbTunnelClient<WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key>,
    isConnectionRefused: @escaping (TunnelServerFactoryType.Configuration.Server.ConnectionErrorType) -> Bool
  ) {
    self.init(
      factory: factory,
      repoFactory: repoFactory,
      key: key,
      tunnelRepo: nil,
      logger: nil,
      server: nil,
      repoClientFactory: repoClientFactory,
      isConnectionRefused: isConnectionRefused
    )
  }

  private init(
    factory:   TunnelServerFactoryType,
    repoFactory: WritableTunnelRepositoryFactoryType,
    key: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key,
    tunnelRepo: WritableTunnelRepositoryFactoryType.TunnelRepositoryType?,
    logger: Logger?,
    server: (any TunnelServer)?,
    repoClientFactory : @escaping (@Sendable @escaping () -> any Application) -> any KVdbTunnelClient<WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key>,
 isConnectionRefused: @escaping (TunnelServerFactoryType.Configuration.Server.ConnectionErrorType) -> Bool
  ) {
    self.factory = factory
    self.repoFactory = repoFactory
    self.key = key
    self.tunnelRepo = tunnelRepo
    self.logger = logger
    self.server = server
    self.repoClientFactory = repoClientFactory
    self.isConnectionRefused = isConnectionRefused
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
      try await tunnelRepo?.saveURL(tunnel.publicURL, withKey: key)
    } catch {
      logger?.error(
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
  private func beginFromApplication(_ application: @Sendable @escaping () -> any Application) async {
    let server = factory.server(
      from:   TunnelServerFactoryType.Configuration(application: application()),
      handler: self
    )
    logger = application().logger
    tunnelRepo = repoFactory.setupClient(
      repoClientFactory(application)
//      VaporKVdbTunnelClient(
//        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self,
//        get: {
//          try await application().get(from: $0)
//        }, post: {
//          try await application().post(to: $0, body: $1)
//        }
//      )
//      VaporTunnelClient(
//        client: application.client,
//        keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self
//      )
    )
    self.server = server
    server.start(isConnectionRefused: isConnectionRefused)
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
