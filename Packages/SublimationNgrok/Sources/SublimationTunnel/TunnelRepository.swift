//
//  TunnelRepository.swift
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

public import Foundation

/// A repository for managing tunnels.
/// This protocol defines the basic functionality for
/// retrieving tunnels based on a given key.
///
/// - Note: The `Key` type must conform to the `Sendable` protocol.
///
/// - Important: This protocol inherits from the `Sendable` protocol.
///
/// - Warning: The `Key` associated type must also conform to the `Sendable` protocol.
///
/// - Requires: The `Key` associated type to be specified.
public protocol TunnelRepository<Key>: Sendable {
  /// The type of key used to retrieve tunnels.
  associatedtype Key: Sendable

  ///   Retrieves a tunnel for the specified key.
  ///
  ///   - Parameter key: The key used to retrieve the tunnel.
  ///
  ///   - Throws: An error if the tunnel cannot be retrieved.
  ///
  ///   - Returns: The URL of the retrieved tunnel, if available.
  func tunnel(forKey key: Key) async throws -> URL?
}
