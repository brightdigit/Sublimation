//
//  NgrokCLIAPIServerFactory.swift
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
import Ngrokit
import NIOCore
import OpenAPIAsyncHTTPClient

public struct NgrokCLIAPIServerFactory: NgrokServerFactory {
  public typealias Configuration = NgrokCLIAPIConfiguration

  private let cliAPI: NgrokCLIAPI
  private let timeout: TimeAmount

  public init(
    cliAPI: NgrokCLIAPI = .init(ngrokPath: "/opt/homebrew/bin/ngrok"),
    timeout: TimeAmount = .seconds(1)
  ) {
    self.cliAPI = cliAPI
    self.timeout = timeout
  }

  public init(ngrokPath: String, timeout: TimeAmount = .seconds(1)) {
    self.init(cliAPI: .init(ngrokPath: ngrokPath), timeout: timeout)
  }

  public func server(
    from configuration: Configuration,
    handler: any NgrokServerDelegate
  ) -> NgrokCLIAPIServer {
    let client = NgrokClient(
      transport: AsyncHTTPClientTransport(configuration: .init(timeout: timeout))
    )

    let process = cliAPI.process(forHTTPPort: configuration.port)
    return .init(
      delegate: handler,
      client: client,
      process: process,
      port: configuration.port,
      logger: configuration.logger
    )
  }
}
