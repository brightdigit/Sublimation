//
//  TXTRecord.swift
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

@available(*, unavailable)
internal protocol TXTRecord {
  var count: Int { get }
  init(_ dictionary: [String: String])
  func getStringEntry(for key: String) -> String?
}

@available(*, unavailable)
extension TXTRecord {
  private init(_ dictionary: [SublimationKey: any CustomStringConvertible]) {
    self.init(.init(sublimationTxt: dictionary))
  }


  internal func getEntry<T: SublimationValue>(for key: SublimationKey, of _: T.Type) -> EntryResult<T> {
    guard let string = getStringEntry(for: key.stringValue) else {
      return .empty
    }
    return .init(string: string)
  }


  private func urlConfiguration(
    at offset: Int,
    port: Int,
    isTLS: Bool,
    logger: LoggingActor?
  ) -> URL.Configuration {
    let scheme = isTLS ? "https" : "http"
    logger?.log { $0.debug("Scheme: \(scheme)") }
    let addressCount = self.count - offset
    return .init(scheme: scheme, port: port, count: addressCount)
  }

}
