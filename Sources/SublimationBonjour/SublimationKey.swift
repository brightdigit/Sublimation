//
//  SublimationKey.swift
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
@available(*, deprecated)
private enum SublimationKeyValues: String {
  case tls = "Sublimation_TLS"
  case port = "Sublimation_Port"
  case address = "Sublimation_Address"
}
@available(*, deprecated)
public enum SublimationKey: Hashable {
  case tls
  case port
  case address(Int)
}
@available(*, deprecated)
extension SublimationKey {
  internal var stringValue: String {
    let value: (any CustomStringConvertible)? = switch self {
    case let .address(index):
      index
    default:
      nil
    }
    let prefix = SublimationKeyValues(key: self).rawValue
    guard let value else {
      return prefix
    }
    return [prefix, value.description].joined(separator: "_")
  }
}
@available(*, deprecated)
extension SublimationKeyValues {
  fileprivate init(key: SublimationKey) {
    switch key {
    case .address:
      self = .address
    case .port:
      self = .port
    case .tls:
      self = .tls
    }
  }
}
@available(*, deprecated)
extension [String: String] {
  internal init(sublimationTxt: [SublimationKey: any CustomStringConvertible]) {
    let pairs = sublimationTxt
      .map { (key: SublimationKey, value: any CustomStringConvertible) in
        (key.stringValue, value.description)
      }
    self.init(uniqueKeysWithValues: pairs)
  }
}
