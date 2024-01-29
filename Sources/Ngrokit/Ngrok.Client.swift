import Foundation
import NgrokOpenAPIClient
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Ngrok {
  public struct Client: Sendable {
    // swiftlint:disable:next force_try
    static let defaultServerURL = try! Servers.server1()
    let underlyingClient: NgrokOpenAPIClient.Client

    public init(serverURL: URL? = nil, transport: any ClientTransport) {
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
      let response = try await underlyingClient.startTunnel(
        .init(
          body: .json(tunnelRequest)
        )
      ).created.body.json
      let tunnel: Tunnel = try .init(response: response)
      return tunnel
    }

    public func stopTunnel(withName name: String) async throws {
      _ = try await underlyingClient.stopTunnel(path: .init(name: name)).noContent
    }

    public func listTunnels() async throws -> [Tunnel] {
      try await underlyingClient
        .listTunnels()
        .ok.body.json.tunnels
        .map(Tunnel.init(response:))
    }
  }
}
