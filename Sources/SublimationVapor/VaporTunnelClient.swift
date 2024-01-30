//
//  VaporTunnelClient.swift
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
import Sublimation
import Vapor

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct VaporTunnelClient<Key: Sendable>: KVdbTunnelClient {
  private let client: any Vapor.Client

  public init(client: any Vapor.Client, keyType _: Key.Type) {
    self.client = client
  }

  public func getValue(
    ofKey key: Key,
    fromBucket bucketName: String
  ) async throws -> URL {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)
    let url: URL?
    url = try await client.get(uri)
      .body
      .map(String.init(buffer:))
      .flatMap(URL.init(string:))

    guard let url else {
      throw NgrokServerError.invalidURL
    }
    return url
  }

  public func saveValue(
    _ value: URL,
    withKey key: Key,
    inBucket bucketName: String
  ) async throws {
    let uri = KVdb.construct(URI.self, forKey: key, atBucket: bucketName)

    let response = try await client.post(uri) { request in
      request.body = .init(string: value.absoluteString)
    }
    .get()

    if response.status.code / 100 == 2 {
      return
    }

    throw NgrokServerError.cantSaveTunnel(response)
  }
}
