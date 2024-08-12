//
//  Application.swift
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
public import Logging

/// Server Application
public protocol Application {
  /// The port number for the HTTP server configuration.
  var httpServerConfigurationPort: Int { get }

  /// Whether the server is running on https or http.
  var httpServerTLS: Bool { get }

  /// The logger for the server application.
  var logger: Logger { get }

  /// Posts data to a url.
  /// - Parameters:
  ///   - url: The url to post to.
  ///   - body: The optional data.
  ///  - Throws: If there's an issue with the request.
  func post(to url: URL, body: Data?) async throws

  /// Makes a client call to a url.
  /// - Parameter url: The url to call.
  /// - Returns: The data returned from that request.
  /// - Throws: If there's an issue with the request.
  func get(from url: URL) async throws -> Data?
}
