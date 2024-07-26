//
//  String.swift
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

internal import Foundation

extension String {
  internal func isLocalhost() -> Bool {
    let localhostNames = ["localhost", "127.0.0.1", "::1"]
    return localhostNames.contains(self)
  }

  internal func isValidIPv6Address() -> Bool {
    var sin6 = sockaddr_in6()
    return self.withCString { cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) } == 1
  }

  internal func formatIPv6ForURL() -> String {
    if isValidIPv6Address() {
      "[\(self)]"
    } else {
      self
    }
  }

  /// Filters strings which are only v4 and not refering the localhost.
  /// - Parameter address: The host address string.
  /// - Returns: True, if the address passes the filter.
  @available(*, deprecated)
  @Sendable
  public static func isIPv4NotLocalhost(_ address: String) -> Bool {
    guard !(["127.0.0.1", "::1", "localhost"].contains(address)) else {
      return false
    }
    guard !address.contains(":") else {
      return false
    }
    return true
  }
}
