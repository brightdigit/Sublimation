//
//  NgrokClient.swift
//  Ngrokit
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

public import Foundation
import NgrokOpenAPIClient
public import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A client for interacting with the Ngrok API.
///
/// Use this client to start and stop tunnels, as well as list existing tunnels.
///
/// To create an instance of `NgrokClient`,
/// you need to provide a transport and an optional server URL.
///
/// ```swift
/// let client = NgrokClient(transport: URLSession.shared)
/// ```
public struct NgrokClient: Sendable {
  // swift-format-ignore: NeverUseForceTry
  /// The default server URL which is `http://127.0.0.1:4040`N.
  public static let defaultServerURL = try! Servers.server1()

  private let underlyingClient: any APIProtocol

  ///   Initializes a new instance of `NgrokClient`.
  ///
  ///   - Parameters:
  ///     - transport: The transport to use for making API requests.
  ///     - serverURL: The server URL to use. If `nil`,
  ///     the default server URL will be used.
  public init(transport: any ClientTransport, serverURL: URL? = nil) {
    let underlyingClient = NgrokOpenAPIClient.Client(
      serverURL: serverURL ?? Self.defaultServerURL,
      transport: transport
    )
    self.init(underlyingClient: underlyingClient)
  }

  internal init(underlyingClient: any APIProtocol) { self.underlyingClient = underlyingClient }
  public func status() async throws { _ = try await self.underlyingClient.get_sol_api().ok }

  ///   Starts a new tunnel.
  ///
  ///   - Parameter request: The tunnel request.
  ///
  ///   - Returns: The created tunnel.
  ///
  ///   - Throws: An error if the tunnel creation fails.
  public func startTunnel(_ request: TunnelRequest) async throws -> NgrokTunnel {
    let tunnelRequest: Components.Schemas.TunnelRequest
    tunnelRequest = .init(request: request)
    let response = try await underlyingClient.startTunnel(.init(body: .json(tunnelRequest))).created
      .body.json
    let tunnel: NgrokTunnel = try .init(response: response)
    return tunnel
  }

  ///   Stops a tunnel with the specified name.
  ///
  ///   - Parameter name: The name of the tunnel to stop.
  ///
  ///   - Throws: An error if the tunnel cannot be stopped.
  public func stopTunnel(withName name: String) async throws {
    _ = try await underlyingClient.stopTunnel(path: .init(name: name)).noContent
  }

  ///   Lists all existing tunnels.
  ///
  ///   - Returns: An array of tunnels.
  ///
  ///   - Throws: An error if the tunnel listing fails.
  public func listTunnels() async throws -> [NgrokTunnel] {
    try await underlyingClient.listTunnels().ok.body.json.tunnels.map(NgrokTunnel.init(response:))
  }
}
