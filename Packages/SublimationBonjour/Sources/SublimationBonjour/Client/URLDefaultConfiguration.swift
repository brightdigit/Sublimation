//
//  URLDefaultConfiguration.swift
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

/// Default Configuration for URLs.
///
/// If the ``BindingConfiguration`` is missing properties such as
/// ``BindingConfiguration/port`` or ``BindingConfiguration/isSecure``
/// ``BonjourClient`` using these settings as fallback.
public struct URLDefaultConfiguration {
  /// Create the default configuration.
  /// - Parameters:
  ///   - isSecure: Whether https or http
  ///   - port: HTTP Server port
  public init(isSecure: Bool = false, port: Int = 8080) {
    self.isSecure = isSecure
    self.port = port
  }
  /// Whether https or http
  public let isSecure: Bool
  /// Server port number.
  public let port: Int
}
