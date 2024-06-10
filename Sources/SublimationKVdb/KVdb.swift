//
//  KVdb.swift
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

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A utility class for interacting with KVdb.
///
/// KVdb is a key-value database service.
///
/// - Note: This class requires the `Foundation` framework.
///
/// - SeeAlso: [KVdb](https://kvdb.io/)
///
/// - Author: Leo Dion
///
/// - Version: 2024
///
/// - License: MIT License
public enum KVdb {
  /// The base URL string for KVdb.
  public static let baseString = "https://kvdb.io/"

  ///   Constructs the path for a given key in a bucket.
  ///
  ///   - Parameters:
  ///     - key: The key for the value.
  ///     - bucketName: The name of the bucket.
  ///
  ///   - Returns: The constructed path.
  public static func path(forKey key: some Any, atBucket bucketName: String) -> String {
    "/\(bucketName)/\(key)"
  }

  ///   Constructs a URL for a given key in a bucket.
  ///
  ///   - Parameters:
  ///     - URLType: The type of URL to construct.
  ///     - key: The key for the value.
  ///     - bucketName: The name of the bucket.
  ///
  ///   - Returns: The constructed URL.
  public static func construct<URLType: KVdbURLConstructable>(
    _: URLType.Type,
    forKey key: some Any,
    atBucket bucketName: String
  ) -> URLType {
    URLType(
      kvDBBase: baseString,
      keyBucketPath: path(forKey: key, atBucket: bucketName)
    )
  }

//  ///   Retrieves the URL for a given key in a bucket.
//  ///
//  ///   - Parameters:
//  ///     - key: The key for the value.
//  ///     - bucketName: The name of the bucket.
//  ///     - session: The URLSession to use for the request. Defaults to `.ephemeral`.
//  ///
//  ///   - Returns: The URL for the key, or `nil` if it doesn't exist.
//  ///
//  ///   - Throws: An error if the request fails.
//  @available(*, deprecated)
//  public static func url<Key: Sendable>(
//    withKey key: Key,
//    atBucket bucketName: String,
//    using session: URLSession = .ephemeral()
//  ) async throws -> URL? {
//    let repository = KVdbTunnelRepository<Key>(
//      client: URLSessionClient<Key>(session: session),
//      bucketName: bucketName
//    )
//    return try await repository.tunnel(forKey: key)
//  }
}
