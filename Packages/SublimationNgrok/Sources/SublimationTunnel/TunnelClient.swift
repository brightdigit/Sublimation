//
//  TunnelClient.swift
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

#if canImport(FoundationNetworking)
  public import FoundationNetworking
#endif

/// A client for interacting with KVdb Tunnel.
///
/// - Note: This client conforms to the `Sendable` protocol.
///
/// - Note: The `Key` type must also conform to the `Sendable` protocol.
///
/// - Warning: This client is not thread-safe.
///
/// - Important: This client requires the `FoundationNetworking` module to be imported.
///
/// - SeeAlso: `KVdbTunnelClientProtocol`
public protocol TunnelClient<Key>: Sendable {
  /// The type of key used to access values in the KVdb Tunnel.
  associatedtype Key: Sendable

  ///   Retrieves the value associated with the specified key from the specified bucket.
  ///
  ///   - Parameters:
  ///     - key: The key used to access the value.
  ///     - bucketName: The name of the bucket.
  ///
  ///   - Returns: The URL of the retrieved value.
  ///
  ///   - Throws: An error if the value cannot be retrieved.
  func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL

  ///   Saves the specified value with the specified key in the specified bucket.
  ///
  ///   - Parameters:
  ///     - value: The URL of the value to be saved.
  ///     - key: The key used to access the value.
  ///     - bucketName: The name of the bucket.
  ///
  ///   - Throws: An error if the value cannot be saved.
  func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws
}
