import Foundation
import Logging
import Ngrokit
import OpenAPIRuntime

public struct NgrokCLIAPIServer: NgrokServer, Sendable {
  private struct TunnelResult {
    let isOld: Bool
    let tunnel: Tunnel
  }

  private let delegate: any NgrokServerDelegate
  private let client: Ngrok.Client
  private let process: NgrokProcess
  private let port: Int
  private let pipe: Pipe
  private let logger: Logger

  public init(
    delegate: any NgrokServerDelegate,
    client: Ngrok.Client,
    process: NgrokProcess,
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
      logger.debug("Ngrok not started. Running Process.")
      try await process.run(onError: cliError(_:))
      try await Task.sleep(for: .seconds(1), tolerance: .seconds(1))

    case let .success(tunnel):
      logger.debug("Process Already Running.")
      return tunnel.map { .init(isOld: true, tunnel: $0) }

    case let .failure(error):
      throw error
    }

    let start = Date()
    var networkResult: NetworkResult<Tunnel?>?
    var lastError: ClientError?
    var attempts = 0
    while networkResult == nil, (-start.timeIntervalSinceNow) < timeout {
      logger.debug("Attempt #\(attempts + 1)")
      networkResult = await NetworkResult {
        try await client.listTunnels().first
      }
      attempts += 1
      switch networkResult {
      case let .connectionRefused(error):
        lastError = error
        networkResult = nil

      default:
        continue
      }
    }

    if let lastError, networkResult == nil {
      logger.debug("Timeout Occured After \(-start.timeIntervalSinceNow) seconds.")
      throw lastError
    }

    let tunnel = try networkResult?.get()?.flatMap { $0 }

    logger.debug("Result at \(-start.timeIntervalSinceNow) seconds.")

    return tunnel.map { .init(isOld: false, tunnel: $0) }
  }

  private func newTunnel() async throws -> Tunnel {
    if let tunnel = try await searchForExistingTunnel(within: 30.0) {
      if tunnel.isOld {
        logger.debug("Existing Tunnel Found. \(tunnel.tunnel.publicURL)")
        try await client.stopTunnel(withName: tunnel.tunnel.name)
        logger.debug("Tunnel Stopped.")
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
    let newTunnel: Tunnel
    do {
      newTunnel = try await self.newTunnel()
    } catch {
      delegate.server(self, errorDidOccur: error)
      return
    }
    logger.debug("New Tunnel Created. \(newTunnel.publicURL)")

    delegate.server(self, updatedTunnel: newTunnel)
  }

  public func start() {
    Task {
      await run()
    }
  }
}
