//
//  TunnelClientRepository.swift
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

public final class TunnelClientRepository<Key: Sendable>: WritableTunnelRepository {
  private let client: any TunnelClient<Key>
  private let bucketName: String
  public init(client: any TunnelClient<Key>, bucketName: String) {
    self.client = client
    self.bucketName = bucketName
  }

  public func tunnel(forKey key: Key) async throws -> URL? {
    try await client.getValue(ofKey: key, fromBucket: bucketName)
  }

  public func saveURL(_ url: URL, withKey key: Key) async throws {
    try await client.saveValue(url, withKey: key, inBucket: bucketName)
  }
}
