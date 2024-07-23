//
//  FileHandle.swift
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

public import Foundation

// swiftlint:disable:next force_try
private let ngrokCLIErrorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")

/// A protocol for handling data.
public protocol DataHandle {
  /// Reads data until the end.
  ///
  /// - Returns: The data read until the end, or `nil` if there is no more data.
  /// - Throws: An error if there was a problem reading the data.
  func readToEnd() throws -> Data?
}

extension FileHandle: DataHandle {}

extension DataHandle {
  /// Parses the ngrok error code from the data.
  ///
  /// - Returns: The parsed ngrok error code.
  /// - Throws: An error if there was a problem parsing the error code.
  internal func parseNgrokErrorCode() throws -> NgrokError {
    guard let data = try readToEnd() else {
      throw RuntimeError.unknownError
    }
    let text = String(decoding: data, as: UTF8.self)

    guard let match = ngrokCLIErrorRegex.firstMatch(
      in: text,
      range: .init(location: 0, length: text.count)
    ), match.numberOfRanges > 0 else {
      throw RuntimeError.unknownEarlyTermination(text)
    }

    guard let range = Range(match.range(at: 1), in: text) else {
      throw RuntimeError.unknownEarlyTermination(text)
    }
    guard let code = Int(text[range]) else {
      throw RuntimeError.unknownEarlyTermination(text)
    }
    guard let error = NgrokError(rawValue: code) else {
      throw RuntimeError.unknownNgrokErrorCode(code)
    }
    return error
  }
}
