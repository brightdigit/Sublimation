import Foundation
import Ngrokit

import class Prch.Client
import PrchVapor
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class NgrokCLIAPIServer: NgrokServer {
  internal init(cli: Ngrok.CLI, prchClient: Client<SessionClient, Ngrok.API>? = nil, port: Int? = nil, logger: Logger? = nil, ngrokProcess: Process? = nil, clientSearchTimeoutNanoseconds: UInt64 = NSEC_PER_SEC / 5, cliProcessTimeout: DispatchTimeInterval = .seconds(2), delegate: NgrokServerDelegate? = nil) {
    self.cli = cli
    self.prchClient = prchClient
    self.port = port
    self.logger = logger
    self.ngrokProcess = ngrokProcess
    self.cliProcessTimeout = cliProcessTimeout
    self.clientSearchTimeoutNanoseconds = clientSearchTimeoutNanoseconds
    self.delegate = delegate
  }

  public convenience init(ngrokPath: String, prchClient: Client<SessionClient, Ngrok.API>? = nil, port: Int? = nil, logger: Logger? = nil, ngrokProcess: Process? = nil, delegate: NgrokServerDelegate? = nil) {
    self.init(cli: .init(executableURL: .init(fileURLWithPath: ngrokPath)), prchClient: prchClient, port: port, logger: logger, ngrokProcess: ngrokProcess, delegate: delegate)
  }

  let cli: Ngrok.CLI
  let clientSearchTimeoutNanoseconds: UInt64
  let cliProcessTimeout: DispatchTimeInterval
  var prchClient: Prch.Client<SessionClient, Ngrok.API>!
  var port: Int?
  var logger: Logger!
  var ngrokProcess: Process? {
    didSet {
      self.ngrokProcess?.terminationHandler = self.ngrokProcessTerminated
    }
  }

  weak var delegate: NgrokServerDelegate?

  func setupLogger(_ logger: Logger) {
    self.logger = logger
  }

  func ngrokProcessTerminated(_: Process) {
    guard let port = self.port else {
      return
    }

    self.startHttpTunnel(port: port)
  }

  func setupClient(_ client: Vapor.Client) {
    self.prchClient = Prch.Client(api: Ngrok.API(), session: SessionClient(client: client))
  }

  public enum TunnelError: Error {
    case noTunnelCreated
  }

  func startHttpTunnel(port: Int) {
    Task {
      let tunnel: NgrokTunnel
      do {
        tunnel = try await self.startHttp(port: port)
      } catch {
        self.delegate?.server(self, failedWithError: error)
        return
      }
      self.delegate?.server(self, updatedTunnel: tunnel)
    }
  }

  public func waitForTaskCompletion<R>(
    withTimeoutInNanoseconds timeout: UInt64,
    _ task: @escaping () async -> R
  ) async -> R? {
    await withTaskGroup(of: R?.self) { group in
      await withUnsafeContinuation { continuation in
        group.addTask {
          continuation.resume()
          return await task()
        }
      }
      group.addTask {
        await Task.yield()
        try? await Task.sleep(nanoseconds: timeout)
        return nil
      }
      defer { group.cancelAll() }
      return await group.next()!
    }
  }

  func startHttp(port: Int) async throws -> NgrokTunnel {
    self.port = port
    self.logger.debug("Starting Ngrok Tunnel...")
    let tunnels: [NgrokTunnel]

    let result = await waitForTaskCompletion(withTimeoutInNanoseconds: self.clientSearchTimeoutNanoseconds) {
      try? await self.prchClient.request(ListTunnelsRequest()).get().response.get().tunnels
    }?.flatMap { $0 }

    if let firstCallTunnels = result {
      tunnels = firstCallTunnels
    } else {
      do {
        self.logger.debug("Starting New Ngrok Client")
        let ngrokProcess = try await cli.http(port: port, timeout: .now() + self.cliProcessTimeout)
        guard let tunnel = try await self.prchClient.request(ListTunnelsRequest()).get().response.get().tunnels.first else {
          ngrokProcess.terminate()
          throw TunnelError.noTunnelCreated
        }
        self.ngrokProcess = ngrokProcess
        self.logger.debug("Created Ngrok Process...")
        return tunnel
      } catch let Ngrok.CLI.RunError.earlyTermination(_, errorCode) where errorCode == 108 {
        self.logger.debug("Ngrok Process Already Created.")
      } catch {
        self.logger.debug("Error thrown: \(error.localizedDescription)")
        throw error
      }

      self.logger.debug("Listing Tunnels")
      tunnels = try await prchClient.request(ListTunnelsRequest()).get().response.get().tunnels
    }

    if let oldTunnel = tunnels.first {
      self.logger.debug("Deleting Existing Tunnel: \(oldTunnel.public_url) ")
      try await prchClient.request(StopTunnelRequest(name: oldTunnel.name)).get().response.get()
    }

    self.logger.debug("Creating Tunnel...")
    let tunnel = try await prchClient.request(StartTunnelRequest(body: .init(port: port))).get().response.get()

    return tunnel
  }
}
