//
//  NgrokClientTests.swift
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

@testable import Ngrokit
import NgrokitMocks
import NgrokOpenAPIClient
import XCTest

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class NgrokClientTests: XCTestCase {
  private func assertTunnelEqual(
    _ actualOutput: NgrokTunnel,
    _ expectedOutput: Components.Schemas.TunnelResponse
  ) {
    XCTAssertEqual(actualOutput.publicURL.absoluteString, expectedOutput.public_url)
    XCTAssertEqual(actualOutput.name, expectedOutput.name)
    XCTAssertEqual(actualOutput.config.addr.absoluteString, expectedOutput.config.addr)
    XCTAssertEqual(actualOutput.config.inspect, expectedOutput.config.inspect)
  }

  
  internal func testStartTunnel() async throws {
    let publicURL = URL.temporaryDirectory()
    let expectedInput = TunnelRequest(
      port: .random(in: 10 ... 100),
      name: UUID().uuidString,
      proto: UUID().uuidString
    )
    let expectedOutput: Components.Schemas.TunnelResponse =
      .init(
        name: UUID().uuidString,
        public_url: publicURL.absoluteString,
        config: .init(addr: UUID().uuidString, inspect: .random())
      )
    let request = Operations.startTunnel.Output.created(
      .init(body: .json(expectedOutput))
    )
    let api = MockAPI(actualStartTunnelResult: .success(request))
    let client = NgrokClient(underlyingClient: api)
    let actualOutput = try await client.startTunnel(expectedInput)

    assertTunnelEqual(actualOutput, expectedOutput)

    let body = await api.startTunnelPassed.last?.body

    guard case let .json(actualInput) = body else {
      XCTFail("Incorrect result \(String(describing: body))")
      return
    }

    XCTAssertEqual(actualInput.name, expectedInput.name)
    XCTAssertEqual(actualInput.addr, expectedInput.addr)
    XCTAssertEqual(actualInput.proto, expectedInput.proto)
  }

  internal func testStopTunnel() async throws {
    let expectedInput = UUID().uuidString
    let api = MockAPI(actualStopTunnelResult: .success(.noContent(.init())))
    let client = NgrokClient(underlyingClient: api)

    try await client.stopTunnel(withName: expectedInput)

    let name = await api.stopTunnelPassed.last?.path.name

    guard let actualInput = name else {
      XCTFail("Incorrect name \(String(describing: name))")
      return
    }

    XCTAssertEqual(actualInput, expectedInput)
  }

  internal func testListTunnel() async throws {
    let expectedTunnels: [Components.Schemas.TunnelResponse] = [
      .init(
        name: UUID().uuidString,
        public_url: URL.temporaryDirectory().absoluteString,
        config: .init(addr: UUID().uuidString, inspect: .random())
      ),
      .init(
        name: UUID().uuidString,
        public_url: URL.temporaryDirectory().absoluteString,
        config: .init(addr: UUID().uuidString, inspect: .random())
      ),
      .init(
        name: UUID().uuidString,
        public_url: URL.temporaryDirectory().absoluteString,
        config: .init(addr: UUID().uuidString, inspect: .random())
      )
    ]
    let api = MockAPI(
      actualListTunnelResult: .success(
        .ok(.init(body: .json(.init(tunnels: expectedTunnels))))
      )
    )
    let client = NgrokClient(underlyingClient: api)
    let actualOutput = try await client.listTunnels()

    zip(actualOutput, expectedTunnels).forEach(assertTunnelEqual)
  }
}
