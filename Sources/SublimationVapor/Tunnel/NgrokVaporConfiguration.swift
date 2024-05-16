//
//  NgrokVaporConfiguration.swift
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

import Vapor

/// A protocol that defines the configuration for Ngrok in a Vapor application.
///
/// This protocol inherits from `NgrokServerConfiguration`.
///
/// To conform to this protocol, implement the `init(application:)` initializer.
///
/// Example usage:
/// ```
/// struct MyNgrokConfiguration: NgrokVaporConfiguration {
///   init(application: Application) {
///     // Configure Ngrok settings here
///   }
/// }
/// ```
///
/// - Note: This protocol is public.
public protocol NgrokVaporConfiguration: NgrokServerConfiguration {
  ///   Initializes a new instance of the configuration.
  ///
  ///   - Parameter application: The Vapor application.
  ///
  ///   - Note: This initializer is required to conform to
  ///   the `NgrokVaporConfiguration` protocol.
  init(application: any Application)
}
