//
//  MockServerApplication.swift
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

package import Foundation
package import Logging
import SublimationCore
import XCTest

package class MockServerApplication: Application {
  package let httpServerConfigurationPort: Int
  package let httpServerTLS: Bool
  package let logger: Logger

  package private(set) var postRequests = [(URL, Data?)]()
  package private(set) var getRequests = [URL]()
  package private(set) var queuedGetResponses = [Result<Data?, any Error>]()
  package private(set) var queuedPostResponses = [Result<Void, any Error>]()
  package init(httpServerConfigurationPort: Int, httpServerTLS: Bool, logger: Logger) {
    self.httpServerConfigurationPort = httpServerConfigurationPort
    self.httpServerTLS = httpServerTLS
    self.logger = logger
  }

  package func post(to url: URL, body: Data?) async throws {
    postRequests.append((url, body))
    try queuedPostResponses.remove(at: 0).get()
  }

  package func get(from url: URL) async throws -> Data? {
    getRequests.append(url)
    return try queuedGetResponses.remove(at: 0).get()
  }
}
