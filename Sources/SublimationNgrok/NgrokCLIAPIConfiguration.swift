//
//  NgrokCLIAPIConfiguration.swift
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

import Logging
import SublimationCore
import SublimationTunnel

/// Configuration for the Ngrok CLI API server.
///
/// - Note: This configuration conforms to `NgrokServerConfiguration` protocol.
///
/// - Note: This configuration conforms to `NgrokVaporConfiguration` protocol.
///
/// - SeeAlso: `NgrokCLIAPIServer`
public struct NgrokCLIAPIConfiguration: TunnelServerConfiguration {
  /// The type of server to use.
  public typealias Server = NgrokCLIAPIServer

  /// The port number to run the server on.
  public let port: Int

  /// The logger to use for logging.
  public let logger: Logger
}

extension NgrokCLIAPIConfiguration {
  ///   Initializes a new instance of
  ///   `NgrokCLIAPIConfiguration` using a `ServerApplication`.
  ///
  ///   - Parameter serverApplication: The server application to use for configuration.
  internal init(serverApplication: any Application) {
    self.init(
      port: serverApplication.httpServerConfigurationPort,
      logger: serverApplication.logger
    )
  }

  ///   Initializes a new instance of `NgrokCLIAPIConfiguration`
  ///   using a `Vapor.Application`.
  ///
  ///   - Parameter application: The Vapor application to use for configuration.

  public init(application: any Application) {
    self.init(serverApplication: application)
  }
}
