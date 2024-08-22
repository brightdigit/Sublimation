//
//  NgrokCLIAPIServerFactory.swift
//  SublimationNgrok
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
public import Ngrokit
public import SublimationTunnel

/// A factory for creating ``NgrokCLIAPIServer``.
public struct NgrokCLIAPIServerFactory<ProcessType: Processable>: TunnelServerFactory {
  /// The configuration type for the Ngrok CLI API server.
  public typealias Configuration = NgrokCLIAPIConfiguration

  /// The Ngrok CLI API instance.
  private let cliAPI: any NgrokCLIAPI

  private let ngrokClient: @Sendable () -> NgrokClient
  internal init(cliAPI: any NgrokCLIAPI, ngrokClient: @escaping @Sendable () -> NgrokClient) {
    self.cliAPI = cliAPI
    self.ngrokClient = ngrokClient
  }

  /// Sets up a factory to create ``NgrokCLIAPIServer``
  /// - Parameters:
  ///   - ngrokPath: Path to the `ngrok` executable.
  ///   - ngrokClient: Creates a client to consume the local `ngrok` REST API.
  public init(ngrokPath: String, ngrokClient: @escaping @Sendable () -> NgrokClient) {
    self.init(
      cliAPI: NgrokProcessCLIAPI<ProcessType>(ngrokPath: ngrokPath),
      ngrokClient: ngrokClient
    )
  }

  ///   Creates a new Ngrok CLI API server.
  ///
  ///   - Parameters:
  ///     - configuration: The configuration for the server.
  ///     - handler: The delegate for the server.
  ///
  ///   - Returns: A new `NgrokCLIAPIServer` instance.

  public func server(from configuration: Configuration, handler: any TunnelServerDelegate)
    -> NgrokCLIAPIServer
  {
    let process = cliAPI.process(forHTTPPort: configuration.port)
    return .init(
      delegate: handler,
      client: self.ngrokClient(),
      process: process,
      port: configuration.port,
      logger: configuration.logger
    )
  }
}
