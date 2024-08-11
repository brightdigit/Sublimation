//
//  KVdbTunnelClient.swift
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

#if canImport(FoundationNetworking)
  public import FoundationNetworking
#endif

/// A client for interacting with the VaporTunnel service.
///
/// This client conforms to the `KVdbTunnelClient` protocol.
///
/// - Note: This client requires the Vapor framework.
///
/// - Warning: This client is only compatible with Swift 5.5 or later.
///
/// - Important: Make sure to import the necessary dependencies before using this client.
///
/// - SeeAlso: `KVdbTunnelClient`
public struct KVdbTunnelClient<Key: Sendable>: Sendable {
  private let get: @Sendable (URL) async throws -> Data?
  private let post: @Sendable (URL, Data?) async throws -> Void

  public init(
    keyType _: Key.Type,
    get: @escaping @Sendable (URL) async throws -> Data?,
    post: @escaping @Sendable (URL, Data?) async throws -> Void
  ) {
    self.get = get
    self.post = post
  }

  ///   Retrieves the value associated with a key from a specific bucket.
  ///
  ///   - Parameter key: The key used to access the value.
  ///   - Parameter bucketName: The name of the bucket where the value is stored.
  ///
  ///   - Throws: `NgrokServerError.invalidURL` if the retrieved URL is invalid.
  ///
  ///   - Returns: The URL associated with the key in the specified bucket.
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let uri = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    let url: URL?
    url = try await get(uri).map { String(decoding: $0, as: UTF8.self) }.flatMap(URL.init(string:))

    guard let url else { throw KVdbServerError.invalidURL }
    return url
  }

  ///   Saves a value with a key in a specific bucket.
  ///
  ///   - Parameter value: The URL value to save.
  ///   - Parameter key: The key used to associate the value.
  ///   - Parameter bucketName: The name of the bucket where the value will be stored.
  ///
  ///   - Throws: `NgrokServerError.cantSaveTunnel` if the tunnel cannot be saved.
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    let uri = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    do { try await self.post(uri, value.absoluteString.data(using: .utf8)) }
    catch { throw KVdbServerError.cantSaveTunnelError(error) }
  }
}
