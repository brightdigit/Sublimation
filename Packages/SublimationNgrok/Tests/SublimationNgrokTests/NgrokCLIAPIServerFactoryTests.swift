//
//  NgrokCLIAPIServerFactoryTests.swift
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

import HTTPTypes
import Ngrokit
import OpenAPIRuntime
import SublimationMocks
import SublimationTunnel
import XCTest
@testable import SublimationNgrok
import NgrokitMocks

internal final class MockTransport: ClientTransport {
  // swiftlint:disable:next unavailable_function
  internal func send(
    _: HTTPTypes.HTTPRequest,
    body _: OpenAPIRuntime.HTTPBody?,
    baseURL _: URL,
    operationID _: String
  ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
    fatalError("Not implemented")
  }
}

internal class NgrokCLIAPIServerFactoryTests: XCTestCase {
  // swiftlint:disable:next function_body_length
  internal func testServer() {
    let loggerLabel = UUID().uuidString
    let application = MockServerApplication(
      httpServerConfigurationPort: .random(in: 10 ... 10_000),
      httpServerTLS: .random(),
      logger: .init(label: loggerLabel)
    )
    let delegateID = UUID()
    let processID = UUID()
    let configuration = NgrokCLIAPIConfiguration(application: application)
    let factory = NgrokCLIAPIServerFactory<MockProcess>(
      cliAPI: MockNgrokCLIAPI(id: processID), ngrokClient: {
        NgrokClient(transport: MockTransport())
      }
    )
    let server = factory.server(
      from: configuration,
      handler: MockServerDelegate(id: delegateID)
    )
    XCTAssertEqual(
      (server.delegate as? MockServerDelegate)?.id,
      delegateID
    )

    XCTAssertEqual(
      server.port,
      application.httpServerConfigurationPort
    )

    XCTAssertEqual(
      (server.process as? MockNgrokProcess)?.id,
      processID
    )
  }
}
