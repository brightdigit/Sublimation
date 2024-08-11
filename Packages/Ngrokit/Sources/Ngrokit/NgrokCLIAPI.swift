//
//  NgrokCLIAPI.swift
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

import Foundation

/// A protocol for interacting with the Ngrok CLI API.
///
/// This protocol extends the `Sendable` protocol.
///
/// - Note: The `Sendable` protocol is not defined in this code snippet.
///
/// - Important: The `NgrokCLIAPI` protocol is not defined in this code snippet.
///
/// - Requires: The `NgrokProcess` type to be defined.
///
/// - SeeAlso: `NgrokProcess`
public protocol NgrokCLIAPI: Sendable {
  ///   Creates a process for the specified HTTP port.
  ///
  ///   - Parameter httpPort: The port number for the HTTP server.
  ///
  ///   - Returns: An instance of `NgrokProcess` for the specified port.
  func process(forHTTPPort httpPort: Int) -> any NgrokProcess
}

/// A type representing a process created by the Ngrok CLI API.
///
/// - Note: The `NgrokProcess` type is not defined in this code snippet.
