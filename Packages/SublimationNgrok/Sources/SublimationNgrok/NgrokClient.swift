//
//  NgrokClient.swift
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
import Logging
import Ngrokit
import OpenAPIRuntime
import SublimationTunnel

extension NgrokClient {
  internal func attemptTunnel(isConnectionRefused: @escaping (ClientError) -> Bool) async
    -> TunnelAttemptResult
  {
    let networkResult = await AnyTunnelNetworkResult(
      { try await self.listTunnels().first },
      isConnectionRefused: isConnectionRefused
    )
    switch networkResult { case .connectionRefused(let error): return .error(error)

      default: return .network(networkResult)
    }
  }

  internal func searchForCreatedTunnel(
    within timeout: TimeInterval,
    logger: Logger,
    isConnectionRefused: @escaping (ClientError) -> Bool
  ) async throws -> (any Tunnel)? {
    let start = Date()
    var networkResult: NetworkResult<(any Tunnel)?, ClientError>?
    var lastError: ClientError?
    var attempts = 0
    while networkResult == nil, (-start.timeIntervalSinceNow) < timeout {
      logger.debug("Attempt #\(attempts + 1)")
      try await Task.sleep(for: .seconds(5), tolerance: .seconds(5))
      let result = await self.attemptTunnel(isConnectionRefused: isConnectionRefused)
      attempts += 1
      switch result { case .network(let newNetworkResult): networkResult = newNetworkResult

        case .error(let error): lastError = error
      }
    }

    if let lastError, networkResult == nil {
      logger.error("Timeout Occured After \(-start.timeIntervalSinceNow) seconds.")
      throw lastError
    }

    return try networkResult?.get()?.flatMap { $0 }
  }
}
