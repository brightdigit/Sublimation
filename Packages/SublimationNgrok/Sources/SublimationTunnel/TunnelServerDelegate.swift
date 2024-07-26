//
//  TunnelServerDelegate.swift
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

/// A delegate protocol for `NgrokServer` that handles server events and errors.
@available(*, deprecated)
public protocol TunnelServerDelegate: AnyObject, Sendable {
  ///   Notifies the delegate that a tunnel has been updated.
  ///
  ///   - Parameters:
  ///     - server: The `NgrokServer` instance that triggered the event.
  ///     - tunnel: The updated `Tunnel` object.
  ///
  ///   - Note: This method is called whenever a tunnel's status or configuration changes.
  func server(_ server: any TunnelServer, updatedTunnel tunnel: any Tunnel)

  ///   Notifies the delegate that an error has occurred.
  ///
  ///   - Parameters:
  ///     - server: The `NgrokServer` instance that triggered the event.
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is called whenever an error occurs during server operations.
  func server(_ server: any TunnelServer, errorDidOccur error: any Error)
}
