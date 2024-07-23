//
//  NgrokCLIAPIServer+TunnelServer.swift
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
public import OpenAPIRuntime
import SublimationTunnel

extension NgrokCLIAPIServer {
  ///   Runs the server.
  public func run(
    isConnectionRefused: @escaping (ClientError) -> Bool) async {
    let start = Date()
    let newTunnel: any Tunnel
    do {
      newTunnel = try await self.newTunnel(isConnectionRefused: isConnectionRefused)
    } catch {
      delegate.server(self, errorDidOccur: error)
      return
    }
    let seconds = Int(-start.timeIntervalSinceNow)
    logger.notice("New Tunnel Created in \(seconds) secs: \(newTunnel.publicURL)")

    delegate.server(self, updatedTunnel: newTunnel)
  }

  ///   Starts the server.
  public func start(
    isConnectionRefused: @escaping @Sendable (ClientError) -> Bool) {
    Task {
      await run(isConnectionRefused: isConnectionRefused)
    }
  }
}
