import Foundation
import Ngrokit

import Prch
import PrchModel

import OpenAPIAsyncHTTPClient
// import class Prch.Client
import PrchVapor
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

@available(*, deprecated)
protocol NgrokServiceProtocol: ServiceProtocol where ServiceAPI == Ngrok.PrchAPI {}

@available(*, deprecated)
class NgrokService<SessionType: Prch.Session>: Service, NgrokServiceProtocol
  where SessionType.ResponseType.DataType == Ngrok.PrchAPI.ResponseDataType,
  SessionType.RequestDataType == Ngrok.PrchAPI.RequestDataType {
  internal init(session: SessionType) {
    self.session = session
  }

  let session: SessionType

  var authorizationManager: any SessionAuthenticationManager {
    NullAuthorizationManager()
  }

  typealias API = Ngrok.PrchAPI

  var api: Ngrok.PrchAPI {
    Ngrok.PrchAPI.shared
  }
}

#if os(macOS)
  final actor NgrokCLIAPIServer: NgrokServer {
    func setDelegate(_ delegate: NgrokServerDelegate) async {
      self.delegate = delegate
    }

    private actor APIClientContainer {
      internal init(apiClient: Ngrok.Client? = nil) {
        self.apiClient = apiClient
      }

      func setupClient(_: HTTPClient) async {
        apiClient = .init(
          transport: AsyncHTTPClientTransport()
        )
      }

      var apiClient: Ngrok.Client?
    }
    internal init(
      cli: Ngrok.CLI,
      apiClient: Ngrok.Client? = nil,
      port: Int? = nil,
      logger: Logger? = nil,
      ngrokProcess: Process? = nil,
      clientSearchTimeoutNanoseconds: UInt64 = NSEC_PER_SEC / 5,
      cliProcessTimeout: DispatchTimeInterval = .seconds(2),
      delegate: NgrokServerDelegate? = nil
    ) {
      self.cli = cli
      self.clientContainer = .init(apiClient: apiClient)
      self.port = port
      self.logger = logger
      self.ngrokProcess = ngrokProcess
      self.cliProcessTimeout = cliProcessTimeout
      self.clientSearchTimeoutNanoseconds = clientSearchTimeoutNanoseconds
      self.delegate = delegate
    }

    public convenience init(
      ngrokPath: String,
      apiClient: Ngrok.Client? = nil,
      port: Int? = nil,
      logger: Logger? = nil,
      ngrokProcess: Process? = nil,
      delegate: NgrokServerDelegate? = nil
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
    let cliProcessTimeout: DispatchTimeInterval
    private let clientContainer: APIClientContainer
    // var apiClient: Ngrok.Client?
    var port: Int?
    var logger: Logger!
    var ngrokProcess: Process? {
      didSet {
        Task {
          if let ngrokProcess = self.ngrokProcess {
            ngrokProcess.terminationHandler = self.ngrokProcessTerminated(_:)
          }
        }
      }
    }

    weak var delegate: NgrokServerDelegate?

    func setupLogger(_ logger: Logger) async {
      self.logger = logger
    }

    func ngrokProcessTerminated(_: Process) {
      guard let port = self.port else {
        return
      }

      Task {
        await startHttpTunnel(port: port)
      }
    }

    var prchClient: Ngrok.Client {
      guard let client = await self.clientContainer.apiClient else {
        fatalError()
      }
      return client
    }

    func setupClient(_ client: HTTPClient) async {
      await self.clientContainer.setupClient(client)
//    apiClient = .init(transport: AsyncHTTPClientTransport(configuration: .init(client: client)))
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
          self.logger.debug("Error: \(error)")
          return []
        }
        // try? await self.prchClient.request(ListTunnelsRequest()).tunnels
      }?.flatMap { $0 }

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
        } catch let Ngrok.CLI.RunError.earlyTermination(_, errorCode)
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
        logger.debug("Deleting Existing Tunnel: \(oldTunnel.public_url) ")
        try await prchClient.stopTunnel(withName: oldTunnel.name)
      }

      logger.debug("Creating Tunnel...")
      let tunnel = try await prchClient.startTunnel(.init(port: port, name: "vapor-development"))
      // .request(StartTunnelRequest(body: .init(port: port)))

      return tunnel
    }
  }
#endif
