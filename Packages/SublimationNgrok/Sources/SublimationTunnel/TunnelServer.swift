//
//  TunnelServer.swift
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

/// A protocol for starting a Ngrok server.
///
/// Implement this protocol to start a Ngrok server.
///
/// - Note: The Ngrok server allows you to expose a local server to the internet.
///
/// - Important: Make sure to call the `start()` method to start the Ngrok server.
public protocol TunnelServer: Sendable {
  /// Type of connection error which denotes whether the service isn't available.
  associatedtype ConnectionErrorType: Error
  ///   Starts the Ngrok server.
  ///
  ///   Call this method to start the Ngrok server and
  ///   expose your local server to the internet.
  @available(*, deprecated) func start(
    isConnectionRefused: @escaping @Sendable (ConnectionErrorType) -> Bool
  )
  func run(isConnectionRefused: @escaping @Sendable (ConnectionErrorType) -> Bool) async throws
  func shutdown()
}
