//
//  MockDataHandle.swift
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
import Ngrokit

package struct MockDataHandle: DataHandle {
  package static let code: Data = .init("""
  ERROR:  authentication failed: Your account is limited to 1 simultaneous ngrok agent session.
  ERROR:  You can run multiple tunnels on a single agent session using a configuration file.
  ERROR:  To learn more, see https://ngrok.com/docs/secure-tunnels/ngrok-agent/reference/config/
  ERROR:
  ERROR:  Active ngrok agent sessions in region 'us':
  ERROR:    - ts_2bjiyVxWh6dMoaZUfjXNsHWFNta (2607:fb90:8da8:5b15:900b:13fd:c5e7:f9c6)
  ERROR:
  ERROR:  ERR_NGROK_108
  ERROR:
  """.utf8)

  private let actualResult: Result<Data?, any Error>

  package init(_ actualResult: Result<Data?, any Error>) {
    self.actualResult = actualResult
  }

  package static func withNgrokCode() -> MockDataHandle {
    .init(.success(code))
  }

  package func readToEnd() throws -> Data? {
    try actualResult.get()
  }
}
