//
//  TunnelRequest.swift
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

import NgrokOpenAPIClient

/// Represents a request to create a tunnel.
public struct TunnelRequest: Sendable {
  /// The address of the tunnel.
  public let addr: String

  /// The protocol to use for the tunnel.
  public let proto: String

  /// The name of the tunnel.
  public let name: String

  ///   Initializes a new `TunnelRequest` instance.
  ///
  ///   - Parameters:
  ///      - addr: The address of the tunnel.
  ///      - proto: The protocol to use for the tunnel.
  ///      - name: The name of the tunnel.
  public init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }

  ///   Initializes a new `TunnelRequest` instance.
  ///
  ///   - Parameters:
  ///      - port: The port number of the tunnel.
  ///      - name: The name of the tunnel.
  ///      - proto: The protocol to use for the tunnel. Default value is "http".
  public init(port: Int, name: String, proto: String = "http") {
    self.init(addr: port.description, proto: proto, name: name)
  }
}

extension Components.Schemas.TunnelRequest {
  ///   Initializes a new `Components.Schemas.TunnelRequest` instance.
  ///
  ///   - Parameters:
  ///      - request: The `TunnelRequest` instance to initialize from.
  internal init(request: TunnelRequest) {
    self.init(addr: request.addr, proto: request.proto, name: request.name)
  }
}
