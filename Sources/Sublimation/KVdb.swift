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

public enum KVdb {
  public static let baseString = "https://kvdb.io/"

  public static func path(forKey key: some Any, atBucket bucketName: String) -> String {
    "/\(bucketName)/\(key)"
  }

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

  public static func url<Key: Sendable>(
    withKey key: Key,
    atBucket bucketName: String,
    using session: URLSession = .ephemeral()
  ) async throws -> URL? {
    let repository = KVdbTunnelRepository<Key>(
      client: URLSessionClient<Key>(session: session),
      bucketName: bucketName
    )
    return try await repository.tunnel(forKey: key)
  }
}
