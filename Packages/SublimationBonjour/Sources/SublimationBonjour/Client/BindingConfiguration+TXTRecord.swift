//
//  BindingConfiguration+TXTRecord.swift
//  SublimationBonjour
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

extension Array where Element == Int {
  fileprivate enum ConsecutiveFailure {
    case emptyArray
    case nonConsecutive(expectedSum: Int, actualSum: Int)
  }
  fileprivate var isNotConsecutive: ConsecutiveFailure? {
    guard !isEmpty else { return ConsecutiveFailure.emptyArray }
    let expectedSum = (count * (count - 1)) / 2
    let actualSum = reduce(0, +)
    guard actualSum == expectedSum else {
      return .nonConsecutive(expectedSum: expectedSum, actualSum: actualSum)
    }
    return nil
  }
}

extension BindingConfiguration {
  private enum TXTRecordError: Error {
    case key(String)
    case index(String)
    case indexMismatch(Array<Int>.ConsecutiveFailure)
    case base64Decoding
  }
  internal init(txtRecordDictionary: [String: String]) throws {
    let pairs =
      try txtRecordDictionary.map { (key: String, value: String) in
        try Self.txtRecordIndexValueFrom(key: key, value: value)
      }
      .sorted { $0.0 < $1.0 }
    if let failure = pairs.map(\.0).isNotConsecutive { throw TXTRecordError.indexMismatch(failure) }
    let values = pairs.map(\.1)
    guard let data: Data = .init(base64Encoded: values.joined()) else {
      throw TXTRecordError.base64Decoding
    }
    try self.init(serializedData: data)
  }
  static func txtRecordIndexValueFrom(key: String, value: String) throws -> (Int, String) {
    let components = key.components(separatedBy: "_")
    guard components.count == 2, components.first == "Sublimation",
      let indexString = components.last
    else { throw TXTRecordError.key(key) }
    guard let index = Int(indexString) else { throw TXTRecordError.index(indexString) }
    return (index, value)
  }
}
