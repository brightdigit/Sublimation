//
//  NgrokProcessCLIAPI.swift
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

/// A struct representing the Ngrok CLI API.
///
/// Use this API to interact with Ngrok and create tunnels.
///
/// - Note: This API requires a valid Ngrok installation.
///
/// - Parameters:
///   - ngrokPath: The path to the Ngrok executable.
///
/// - SeeAlso: `NgrokCLIAPI`
public struct NgrokProcessCLIAPI<ProcessType: Processable> {
  /// The path to the Ngrok executable.
  public let ngrokPath: String

  ///   Initializes a new instance of `NgrokProcessCLIAPI`.
  ///
  ///   - Parameter ngrokPath: The path to the Ngrok executable.
  public init(ngrokPath: String) {
    self.ngrokPath = ngrokPath
  }
}

extension NgrokProcessCLIAPI: NgrokCLIAPI {
  ///   Creates a new `NgrokProcess` for the specified HTTP port.
  ///
  ///   - Parameter httpPort: The port number for the HTTP server.
  ///
  ///   - Returns: An instance of `NgrokProcess` for the specified HTTP port.
  public func process(forHTTPPort httpPort: Int) -> any NgrokProcess {
    NgrokMacProcess(
      ngrokPath: ngrokPath,
      httpPort: httpPort,
      processType: ProcessType.self
    )
  }
}
