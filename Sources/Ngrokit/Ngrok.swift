import Foundation
import NgrokOpenAPIClient
import OpenAPIRuntime
import Prch
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

#if os(macOS)
  public typealias TerminationReason = Process.TerminationReason
#else
  public enum TerminationReason: Int {
    case exit = 1

    case uncaughtSignal = 2
  }
#endif

public struct Tunnel {
  internal init(name: String, public_url: URL, config: NgrokTunnelConfiguration) {
    self.name = name
    self.public_url = public_url
    self.config = config
  }

  public let name: String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config: NgrokTunnelConfiguration
}

public enum RuntimeError: Error {
  case invalidURL(String)
  case earlyTermination(TerminationReason, Int?)
  case invalidErrorData(Data)
}

extension Tunnel {
  init(response: Components.Schemas.TunnelResponse) throws {
    guard let public_url = URL(string: response.public_url) else {
      throw RuntimeError.invalidURL(response.public_url)
    }
    guard let addr = URL(string: response.config.addr) else {
      throw RuntimeError.invalidURL(response.config.addr)
    }
    self.init(
      name: response.name,
      public_url: public_url,
      config: .init(
        addr: addr,
        inspect: response.config.inspect
      )
    )
  }
}

public struct TunnelRequest {
  internal init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }

  public init(port: Int, proto: String = "http", name: String) {
    self.init(addr: port.description, proto: proto, name: name)
  }

  public let addr: String
  public let proto: String
  public let name: String
}

extension Components.Schemas.TunnelRequest {
  init(request: TunnelRequest) {
    self.init(addr: request.addr, proto: request.proto, name: request.name)
  }
}

public enum Ngrok {
  // swiftlint:disable:next force_try
  static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")

  public struct Client: Sendable {
    static let defaultServerURL = try! Servers.server1()
    let underlyingClient: NgrokOpenAPIClient.Client

    public init(serverURL: URL? = nil, transport: ClientTransport) {
      let underlyingClient = NgrokOpenAPIClient.Client(
        serverURL: serverURL ?? Self.defaultServerURL,
        transport: transport
      )
      self.init(underlyingClient: underlyingClient)
    }

    private init(underlyingClient: NgrokOpenAPIClient.Client) {
      self.underlyingClient = underlyingClient
    }

    public func startTunnel(_ request: TunnelRequest) async throws -> Tunnel {
      let tunnelRequest: Components.Schemas.TunnelRequest
      tunnelRequest = .init(request: request)
      let response = try await underlyingClient.startTunnel(.init(body: .json(tunnelRequest))).created.body.json
      let tunnel: Tunnel = try .init(response: response)
      return tunnel
    }

    public func stopTunnel(withName name: String) async throws {
      _ = try await underlyingClient.stopTunnel(path: .init(name: name)).noContent
    }

    public func listTunnels() async throws -> [Tunnel] {
      try await underlyingClient.listTunnels().ok.body.json.tunnels.map(Tunnel.init(response:))
    }
  }

  @available(*, deprecated)
  public struct PrchAPI: PrchModel.API {
    public let encoder: any PrchModel.Encoder<Data> = JSONEncoder()

    public let decoder: any PrchModel.Decoder<Data> = JSONDecoder()

    public typealias DataType = Data

    public let baseURLComponents = URLComponents(string: "http://127.0.0.1:4040")!

    public let headers: [String: String] = [:]

    public static let shared: PrchAPI = .init()
  }

  #if os(macOS)
    public struct CLI: Sendable {
      public init(executableURL: URL) {
        self.executableURL = executableURL
      }

      let executableURL: URL

      private func processTerminated(_: Process) {}

      public func http(port: Int, timeout: DispatchTime) async throws -> Process {
        let process = Process()
        let pipe = Pipe()
        let semaphore = DispatchSemaphore(value: 0)
        process.executableURL = executableURL
        process.arguments = ["http", port.description]
        process.standardError = pipe
        process.terminationHandler = { _ in
          semaphore.signal()
        }
        try process.run()
        return try await withCheckedThrowingContinuation { continuation in
          let semaphoreResult = semaphore.wait(timeout: timeout)
          guard semaphoreResult == .success else {
            process.terminationHandler = nil
            continuation.resume(returning: process)
            return
          }
          let errorCode: Int?

          do {
            errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
          } catch {
            continuation.resume(with: .failure(error))
            return
          }
          continuation.resume(with:
            .failure(
              RuntimeError.earlyTermination(process.terminationReason, errorCode))
          )
        }
      }
    }
  #endif
}
