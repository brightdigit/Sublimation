import Foundation
import Ngrokit

extension FileHandle {
  // swiftlint:disable:next force_try
  static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
  func parseNgrokErrorCode() throws -> Int? {
    guard let data = try readToEnd() else {
      return nil
    }

    guard let text = String(data: data, encoding: .utf8) else {
      throw RuntimeError.invalidErrorData(data)
    }

    guard let match = FileHandle.errorRegex.firstMatch(
      in: text,
      range: .init(location: 0, length: text.count)
    ), match.numberOfRanges > 0 else {
      return nil
    }

    guard let range = Range(match.range(at: 1), in: text) else {
      return nil
    }
    return Int(text[range])
  }
}
