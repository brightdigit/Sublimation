//
//  URLSessionClient.swift
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
public import SublimationTunnel

#if canImport(FoundationNetworking)
  @preconcurrency public import FoundationNetworking
#endif

/// A client for interacting with a KVdb tunnel using URLSession.
///
/// This client conforms to the `KVdbTunnelClient` protocol.
///
/// - Note: This client requires the `FoundationNetworking` module to be imported.
///
/// - Warning: The `saveValue(_:withKey:inBucket:)` method will throw
/// a `NgrokServerError` if the save operation fails.
///
/// - SeeAlso: `KVdbTunnelClient`
public struct URLSessionClient<Key: Sendable>: TunnelClient {
  private let session: URLSession

  ///   Initializes a new `URLSessionClient` with the specified session.
  ///
  ///   - Parameter session: The URLSession to use for network requests.
  ///   Defaults to an ephemeral session.
  public init(session: URLSession = .ephemeral()) { self.session = session }

  ///   Retrieves the value associated with a key from a specific bucket.
  ///
  ///   - Parameters:
  ///     - key: The key to retrieve the value for.
  ///     - bucketName: The name of the bucket to retrieve the value from.
  ///
  ///   - Returns: The URL value associated with the key.
  ///
  ///   - Throws: A `NgrokServerError` if the retrieval operation fails.
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)

    let data = try await session.data(from: url).0

    let urlString = String(decoding: data, as: UTF8.self)
    guard let url = URL(string: urlString) else { throw KVdbServerError.invalidURL }

    return url
  }

  ///   Saves a URL value with a specified key in a specific bucket.
  ///
  ///   - Parameters:
  ///     - value: The URL value to save.
  ///     - key: The key to associate with the value.
  ///     - bucketName: The name of the bucket to save the value in.
  ///
  ///   - Throws: A `NgrokServerError` if the save operation fails.
  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    var request = URLRequest(url: url)
    request.httpBody = value.absoluteString.data(using: .utf8)
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw KVdbServerError.cantSaveTunnel(nil, nil)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw KVdbServerError.cantSaveTunnel(httpResponse.statusCode, data)
    }
  }
}
