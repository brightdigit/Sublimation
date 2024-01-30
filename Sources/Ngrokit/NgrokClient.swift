//
//  NgrokClient.swift
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
import NgrokOpenAPIClient
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokClient: Sendable {
  // swiftlint:disable:next force_try
  public static let defaultServerURL = try! Servers.server1()

  private let underlyingClient: NgrokOpenAPIClient.Client

  public init(transport: any ClientTransport, serverURL: URL? = nil) {
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
