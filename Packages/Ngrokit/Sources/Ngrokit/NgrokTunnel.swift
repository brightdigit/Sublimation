//
//  NgrokTunnel.swift
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

public import Foundation
import NgrokOpenAPIClient

/// A struct representing a tunnel.
///
/// - Note: This struct conforms to the `Sendable` protocol.
///
/// - Parameters:
///   - name: The name of the tunnel.
///   - publicURL: The public URL of the tunnel.
///   - config: The configuration of the tunnel.
///
/// - SeeAlso: `NgrokTunnelConfiguration`
///
/// - Throws: `RuntimeError.invalidURL` if the public URL or the address URL is invalid.
///
/// - SeeAlso: `RuntimeError`
///
/// - Note: This struct has an additional initializer
/// that takes a `TunnelResponse` object.
///
/// - SeeAlso: `Components.Schemas.TunnelResponse`
public struct NgrokTunnel: Sendable {
  /// The name of the tunnel.
  public let name: String

  /// The public URL of the tunnel.
  public let publicURL: URL

  /// The configuration of the tunnel.
  public let config: NgrokTunnelConfiguration

  ///   Initializes a new `Tunnel` instance.
  ///
  ///   - Parameters:
  ///     - name: The name of the tunnel.
  ///     - publicURL: The public URL of the tunnel.
  ///     - config: The configuration of the tunnel.
  public init(name: String, publicURL: URL, config: NgrokTunnelConfiguration) {
    self.name = name
    self.publicURL = publicURL
    self.config = config
  }
}

extension NgrokTunnel {
  ///   Initializes a new `Tunnel` instance from a `TunnelResponse` object.
  ///
  ///   - Parameters:
  ///     - response: The `TunnelResponse` object.
  ///
  ///   - Throws: `RuntimeError.invalidURL`
  ///   if the public URL or the address URL is invalid.
  ///
  ///   - SeeAlso: `RuntimeError`
  ///
  ///   - Note: This initializer is internal and should not be used directly.
  ///
  ///   - SeeAlso: `Components.Schemas.TunnelResponse`

  internal init(response: Components.Schemas.TunnelResponse) throws {
    guard let publicURL = URL(string: response.public_url) else {
      throw RuntimeError.invalidURL(response.public_url)
    }
    guard let addr = URL(string: response.config.addr) else {
      throw RuntimeError.invalidURL(response.config.addr)
    }
    self.init(
      name: response.name,
      publicURL: publicURL,
      config: .init(
        addr: addr,
        inspect: response.config.inspect
      )
    )
  }
}
