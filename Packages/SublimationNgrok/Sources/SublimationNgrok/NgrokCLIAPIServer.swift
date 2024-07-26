//
//  NgrokCLIAPIServer.swift
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
public import Logging
public import Ngrokit
public import OpenAPIRuntime
public import SublimationTunnel

/// A server implementation for Ngrok CLI API.
///
/// - Note: This server conforms to the `NgrokServer` and `Sendable` protocols.
///
/// - SeeAlso: `NgrokServer`
/// - SeeAlso: `Sendable`
public struct NgrokCLIAPIServer: TunnelServer, Sendable {
  public typealias ConnectionErrorType = ClientError

  private struct TunnelResult {
    let isOld: Bool
    let tunnel: any Tunnel
  }

  /// The delegate for the server.
  internal let delegate: any TunnelServerDelegate

  /// The client for interacting with Ngrok.
  private let client: NgrokClient

  /// The process for running Ngrok.
  internal let process: any NgrokProcess

  /// The port number to use.
  internal let port: Int

  /// The logger for logging server events.
  internal let logger: Logger

  ///   Initializes a new instance of `NgrokCLIAPIServer`.
  ///
  ///   - Parameters:
  ///     - delegate: The delegate for the server.
  ///     - client: The client for interacting with Ngrok.
  ///     - process: The process for running Ngrok.
  ///     - port: The port number to use.
  ///     - logger: The logger for logging server events.
  public init(
    delegate: any TunnelServerDelegate,
    client: NgrokClient,
    process: any NgrokProcess,
    port: Int,
    logger: Logger
  ) {
    self.delegate = delegate
    self.client = client
    self.process = process
    self.port = port
    self.logger = logger
  }

  ///   Handles a CLI error.
  ///
  ///   - Parameter error: The error that occurred.
  @Sendable
  @available(*, deprecated)
  private func cliError(_ error: any Error) {
    delegate.server(self, errorDidOccur: error)
  }
  
  @available(*, deprecated)
  private func searchForExistingTunnel(
    within timeout: TimeInterval,
    isConnectionRefused: @escaping (ClientError) -> Bool
  ) async throws -> TunnelResult? {
    logger.debug("Starting Search for Existing Tunnel")

    let result = await NetworkResult(
      { try await client.listTunnels().first },
      isConnectionRefused: isConnectionRefused
    )

    if let tunnel = try await self.getTunnel(from: result, onTerminationError: self.cliError(_:)) {
      return tunnel
    }

    return try await client.searchForCreatedTunnel(
      within: timeout,
      logger: logger,
      isConnectionRefused: isConnectionRefused
    )
    .map {
      .init(isOld: false, tunnel: $0)
    }
  }
  
  private func searchForExistingTunnel(
    within timeout: TimeInterval,
    isConnectionRefused: @escaping (ClientError) -> Bool,
    onTerminationError: @Sendable @escaping (any Error) -> Void
  ) async throws -> TunnelResult? {
    logger.debug("Starting Search for Existing Tunnel")

    let result = await NetworkResult(
      { try await client.listTunnels().first },
      isConnectionRefused: isConnectionRefused
    )

    if let tunnel = try await self.getTunnel(from: result, onTerminationError: onTerminationError) {
      return tunnel
    }

    return try await client.searchForCreatedTunnel(
      within: timeout,
      logger: logger,
      isConnectionRefused: isConnectionRefused
    )
    .map {
      .init(isOld: false, tunnel: $0)
    }
  }

  private func getTunnel(
    from result: NetworkResult<NgrokTunnel?, ClientError>,
    onTerminationError: @Sendable @escaping (any Error) -> Void
  ) async throws -> TunnelResult?? {
    switch result {
    case .connectionRefused:
      logger.notice(
        "Ngrok not running. Waiting for Process and New Tunnel... (about 30 secs)"
      )
      try await process.run(onError: onTerminationError)

    case let .success(tunnel):
      logger.debug("Process Already Running.")
      return TunnelResult??.some(tunnel.map { .init(isOld: true, tunnel: $0) })

    case let .failure(error):
      throw error
    }
    return nil
  }
  

  internal func newTunnel(
    isConnectionRefused: @Sendable @escaping (ClientError) -> Bool,
    onTerminationError: @Sendable @escaping (any Error) -> Void
  ) async throws -> any Tunnel {
    if let tunnel = try await searchForExistingTunnel(
      within: 60.0,
      isConnectionRefused: isConnectionRefused,
      onTerminationError: onTerminationError
    ) {
      if tunnel.isOld {
        try await client.stopTunnel(withName: tunnel.tunnel.name)
        logger.info("Existing Tunnel Stopped. \(tunnel.tunnel.publicURL)")
      } else {
        return tunnel.tunnel
      }
    }

    return try await client.startTunnel(
      .init(
        port: port,
        name: "vapor-development"
      )
    )
  }
  
  internal func status () async throws {    
    try await self.client.status()
  }

  internal func newTunnel(
    isConnectionRefused: @escaping (ClientError) -> Bool
  ) async throws -> any Tunnel {
    if let tunnel = try await searchForExistingTunnel(
      within: 60.0,
      isConnectionRefused: isConnectionRefused
    ) {
      if tunnel.isOld {
        try await client.stopTunnel(withName: tunnel.tunnel.name)
        logger.info("Existing Tunnel Stopped. \(tunnel.tunnel.publicURL)")
      } else {
        return tunnel.tunnel
      }
    }

    return try await client.startTunnel(
      .init(
        port: port,
        name: "vapor-development"
      )
    )
  }
}
