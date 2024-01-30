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
import Logging
import Ngrokit
import OpenAPIRuntime

public struct NgrokCLIAPIServer: NgrokServer, Sendable {
  private enum TunnelAttemptResult {
    case network(NetworkResult<Tunnel?>)
    case error(ClientError)
  }

  private struct TunnelResult {
    let isOld: Bool
    let tunnel: Tunnel
  }

  private let delegate: any NgrokServerDelegate
  private let client: NgrokClient
  private let process: any NgrokProcess
  private let port: Int
  private let pipe: Pipe
  private let logger: Logger

  public init(
    delegate: any NgrokServerDelegate,
    client: NgrokClient,
    process: any NgrokProcess,
    port: Int,
    logger: Logger
  ) {
    self.delegate = delegate
    self.client = client
    pipe = Pipe()
    self.process = process
    self.port = port
    self.logger = logger
  }

  private static func attemptTunnel(
    withClient client: NgrokClient
  ) async -> TunnelAttemptResult {
    let networkResult = await NetworkResult {
      try await client.listTunnels().first
    }
    // attempts += 1
    switch networkResult {
    case let .connectionRefused(error):
      return .error(error)

    default:

      return .network(networkResult)
    }
  }

  private static func searchForCreatedTunnel(
    withClient client: NgrokClient,
    within timeout: TimeInterval,
    logger: Logger
  ) async throws -> Tunnel? {
    let start = Date()
    var networkResult: NetworkResult<Tunnel?>?
    var lastError: ClientError?
    var attempts = 0
    while networkResult == nil, (-start.timeIntervalSinceNow) < timeout {
      logger.debug("Attempt #\(attempts + 1)")
      try await Task.sleep(for: .seconds(5), tolerance: .seconds(5))
      let result = await attemptTunnel(withClient: client)
      attempts += 1
      switch result {
      case let .network(newNetworkResult):
        networkResult = newNetworkResult

      case let .error(error):
        lastError = error
      }
    }

    if let lastError, networkResult == nil {
      logger.error("Timeout Occured After \(-start.timeIntervalSinceNow) seconds.")
      throw lastError
    }

    return try networkResult?.get()?.flatMap { $0 }
  }

  @Sendable
  private func cliError(_ error: any Error) {
    delegate.server(self, errorDidOccur: error)
  }

  private func searchForExistingTunnel(
    within timeout: TimeInterval
  ) async throws -> TunnelResult? {
    logger.debug("Starting Search for Existing Tunnel")

    let result = await NetworkResult {
      try await client.listTunnels().first
    }

    switch result {
    case .connectionRefused:
      logger.notice(
        "Ngrok not running. Waiting for Process and New Tunnel... (about 30 secs)"
      )
      try await process.run(onError: cliError(_:))

    case let .success(tunnel):
      logger.debug("Process Already Running.")
      return tunnel.map { .init(isOld: true, tunnel: $0) }

    case let .failure(error):
      throw error
    }

    return try await Self.searchForCreatedTunnel(
      withClient: client,
      within: timeout,
      logger: logger
    )
    .map {
      .init(isOld: false, tunnel: $0)
    }
  }

  private func newTunnel() async throws -> Tunnel {
    if let tunnel = try await searchForExistingTunnel(within: 60.0) {
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

  public func run() async {
    let start = Date()
    let newTunnel: Tunnel
    do {
      newTunnel = try await self.newTunnel()
    } catch {
      delegate.server(self, errorDidOccur: error)
      return
    }
    let seconds = Int(-start.timeIntervalSinceNow)
    logger.notice("New Tunnel Created in \(seconds) secs: \(newTunnel.publicURL)")

    delegate.server(self, updatedTunnel: newTunnel)
  }

  public func start() {
    Task {
      await run()
    }
  }
}
