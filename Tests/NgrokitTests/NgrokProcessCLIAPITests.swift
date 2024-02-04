//
//  NgrokProcessCLIAPITests.swift
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
import XCTest

internal class NgrokProcessCLIAPITests: XCTestCase {
  internal func testProcess() async throws {
    let ngrokPath = UUID().uuidString
    let httpPort = Int.random(in: 10 ... 10_000)
    let api = NgrokProcessCLIAPI<MockProcess>(ngrokPath: ngrokPath)
    let process = api.process(forHTTPPort: httpPort)

    let macProcess = process as? NgrokMacProcess<MockProcess>

    XCTAssertNotNil(macProcess)

    let mockProcess = await macProcess?.process

    XCTAssertNotNil(mockProcess)

    XCTAssertEqual(mockProcess?.executableFilePath, ngrokPath)
    XCTAssertEqual(mockProcess?.port, httpPort)
    XCTAssertEqual(mockProcess?.scheme, "http")
  }
}
