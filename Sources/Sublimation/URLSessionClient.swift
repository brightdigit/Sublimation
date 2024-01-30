//
//  URLSessionClient.swift
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

public struct URLSessionClient<Key: Sendable>: KVdbTunnelClient {
  private let session: URLSession
  public init(session: URLSession = .ephemeral()) {
    self.session = session
  }

  public func getValue(
    ofKey key: Key,
    fromBucket bucketName: String
  ) async throws -> URL {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)

    let data = try await session.dataAsync(from: url).0

    guard let url = String(data: data, encoding: .utf8).flatMap(URL.init(string:)) else {
      throw NgrokServerError.invalidURL
    }

    return url
  }

  public func saveValue(
    _ value: URL,
    withKey key: Key,
    inBucket bucketName: String
  ) async throws {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    var request = URLRequest(url: url)
    request.httpBody = value.absoluteString.data(using: .utf8)
    let (data, response) = try await session.dataAsync(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel(nil, nil)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel(httpResponse.statusCode, data)
    }
  }
}
