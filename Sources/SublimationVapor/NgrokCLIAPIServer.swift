import Foundation
import Ngrokit

import OpenAPIAsyncHTTPClient

// import class Prch.Client
import Vapor
#if canImport(FoundationNetworking)
  import FoundationNetworking

  // swiftlint:disable:next identifier_name
  private let NSEC_PER_SEC: UInt64 = 1_000_000_000
#endif

enum NgrokDefaults {
  public static let defaultBaseURLComponents =
    URLComponents(string: "http://127.0.0.1:4040")!
}

#if os(macOS)
  final actor NgrokCLIAPIServer: NgrokServer {
    func setDelegate(_ delegate: any NgrokServerDelegate) async {
      self.delegate = delegate
    }

    private actor APIClientContainer {
      init(apiClient: Ngrok.Client? = nil) {
        self.apiClient = apiClient
      }

      func setupClient(_: HTTPClient) async {
        apiClient = .init(
          transport: AsyncHTTPClientTransport()
        )
      }

      var apiClient: Ngrok.Client?
    }

    init(
      cli: Ngrok.CLI,
      apiClient: Ngrok.Client? = nil,
      port: Int? = nil,
      logger: Logger? = nil,
      ngrokProcess: Process? = nil,
      clientSearchTimeoutNanoseconds: UInt64 = NSEC_PER_SEC / 5,
      cliProcessTimeout: DispatchTimeInterval = .seconds(5),
      delegate: (any NgrokServerDelegate)? = nil
    ) {
      self.cli = cli
      clientContainer = .init(apiClient: apiClient)
      self.port = port
      self.logger = logger
      self.ngrokProcess = ngrokProcess
      self.cliProcessTimeout = cliProcessTimeout
      self.clientSearchTimeoutNanoseconds = clientSearchTimeoutNanoseconds
      self.delegate = delegate
    }

    public init(
      ngrokPath: String,
      apiClient: Ngrok.Client? = nil,
      port: Int? = nil,
      logger: Logger? = nil,
      ngrokProcess: Process? = nil,
      delegate: (any NgrokServerDelegate)? = nil
    ) {
      self.init(
        cli: .init(executableURL: .init(fileURLWithPath: ngrokPath)),
        apiClient: apiClient,
        port: port,
        logger: logger,
        ngrokProcess: ngrokProcess,
        delegate: delegate
      )
    }

    let cli: Ngrok.CLI
    let clientSearchTimeoutNanoseconds: UInt64
    @available(*, deprecated, message: "Use listTunnels timeout")
    let cliProcessTimeout: DispatchTimeInterval
    private let clientContainer: APIClientContainer
    var port: Int?
    var logger: Logger!
    var ngrokProcess: Process? {
      didSet {
        if let ngrokProcess {
          ngrokProcess.terminationHandler = { process in
            Task {
              await self.ngrokProcessTerminated(process)
            }
          }
        }
      }
    }

    weak var delegate: (any NgrokServerDelegate)?

    func setupLogger(_ logger: Logger) async {
      self.logger = logger
    }

    func ngrokProcessTerminated(_: Process) {
      guard let port else {
        return
      }

      Task {
        await startHttpTunnel(port: port)
      }
    }

    var prchClient: Ngrok.Client {
      get async {
        guard let client = await clientContainer.apiClient else {
          fatalError()
        }
        return client
      }
    }

    func setupClient(_ client: HTTPClient) async {
      await clientContainer.setupClient(client)
    }

    public enum TunnelError: Error {
      case noTunnelCreated
    }

    func startHttpTunnel(port: Int) async {
      Task {
        let tunnel: Tunnel
        do {
          tunnel = try await self.startHttp(port: port)
        } catch {
          self.delegate?.server(self, failedWithError: error)
          return
        }
        self.delegate?.server(self, updatedTunnel: tunnel)
      }
    }

    public func waitForTaskCompletion<R: Sendable>(
      withTimeoutInNanoseconds timeout: UInt64,
      _ task: @escaping @Sendable () async -> R
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

    func startHttp(port: Int) async throws -> Tunnel {
      self.port = port
      logger.debug("Starting Ngrok Tunnel...")
      let tunnels: [Tunnel]

      let result: [Tunnel]? = await waitForTaskCompletion(
        withTimeoutInNanoseconds: clientSearchTimeoutNanoseconds
      ) {
        do {
          return try await self.prchClient.listTunnels()
        } catch {
          await self.logger.debug("Error: \(error)")
          return []
        }
      }?.compactMap { $0 }

      if let firstCallTunnels = result {
        tunnels = firstCallTunnels
      } else {
        do {
          logger.debug("Starting New Ngrok Client")
          let ngrokProcess = try await cli.http(
            port: port,
            timeout: .now() + cliProcessTimeout
          )
          guard let tunnel = try await prchClient.listTunnels().first else {
            ngrokProcess.terminate()
            throw TunnelError.noTunnelCreated
          }
          self.ngrokProcess = ngrokProcess
          logger.debug("Created Ngrok Process...")
          return tunnel
        } catch let RuntimeError.earlyTermination(_, errorCode)
          where errorCode == 108 {
          logger.debug("Ngrok Process Already Created.")
        } catch {
          logger.debug("Error thrown: \(error.localizedDescription)")
          throw error
        }

        logger.debug("Listing Tunnels")
        tunnels = try await prchClient.listTunnels()
      }

      if let oldTunnel = tunnels.first {
        logger.debug("Deleting Existing Tunnel: \(oldTunnel.publicURL) ")
        try await prchClient.stopTunnel(withName: oldTunnel.name)
      }

      logger.debug("Creating Tunnel...")
      let tunnel = try await prchClient.startTunnel(
        .init(
          port: port,
          name: "vapor-development"
        )
      )

      return tunnel
    }
  }
#endif
