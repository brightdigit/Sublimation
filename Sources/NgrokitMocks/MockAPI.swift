//
//  MockAPI.swift
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
import NgrokOpenAPIClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

package final actor MockAPI: APIProtocol {
  private let actualStopTunnelResult: Result<Operations.stopTunnel.Output, any Error>?
  package private(set) var stopTunnelPassed: [Operations.stopTunnel.Input] = []

  private let actualStartTunnelResult: Result<Operations.startTunnel.Output, any Error>?
  package private(set) var startTunnelPassed: [Operations.startTunnel.Input] = []

  private let actualListTunnelResult: Result<Operations.listTunnels.Output, any Error>?
  package private(set) var listTunnelPassed: [Operations.listTunnels.Input] = []

  package init(
    actualStopTunnelResult: Result<Operations.stopTunnel.Output, any Error>? = nil,
    actualStartTunnelResult: Result<Operations.startTunnel.Output, any Error>? = nil,
    actualListTunnelResult: Result<Operations.listTunnels.Output, any Error>? = nil
  ) {
    self.actualStopTunnelResult = actualStopTunnelResult
    self.actualStartTunnelResult = actualStartTunnelResult
    self.actualListTunnelResult = actualListTunnelResult
  }

  // swiftlint:disable unavailable_function force_unwrapping
  package func getTunnel(
    _: NgrokOpenAPIClient.Operations.getTunnel.Input
  ) async throws -> NgrokOpenAPIClient.Operations.getTunnel.Output {
    fatalError("not implemented")
  }

  package func stopTunnel(
    _ input: Operations.stopTunnel.Input
  ) async throws -> Operations.stopTunnel.Output {
    stopTunnelPassed.append(input)
    return try actualStopTunnelResult!.get()
  }

  package func startTunnel(
    _ input: Operations.startTunnel.Input
  ) async throws -> Operations.startTunnel.Output {
    startTunnelPassed.append(input)
    return try actualStartTunnelResult!.get()
  }

  package func listTunnels(
    _ input: NgrokOpenAPIClient.Operations.listTunnels.Input
  ) async throws -> NgrokOpenAPIClient.Operations.listTunnels.Output {
    listTunnelPassed.append(input)
    return try actualListTunnelResult!.get()
  }

  package func get_sol_api(
    _: NgrokOpenAPIClient.Operations.get_sol_api.Input
  ) async throws -> NgrokOpenAPIClient.Operations.get_sol_api.Output {
    fatalError("not implemented")
  }
  // swiftlint:enable unavailable_function force_unwrapping
}
