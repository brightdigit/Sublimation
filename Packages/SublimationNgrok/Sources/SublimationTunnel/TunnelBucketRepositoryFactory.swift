//
//  TunnelBucketRepositoryFactory.swift
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

/// This factory is used to set up and configure a
/// `KVdbTunnelRepository` with a specific bucket name.
public struct TunnelBucketRepositoryFactory<Key: Sendable>:
  WritableTunnelRepositoryFactory {
  /// The type of tunnel repository created by this factory.
  public typealias TunnelRepositoryType = TunnelClientRepository<Key>

  /// The name of the bucket to use.
  public let bucketName: String

  ///   Initializes a new instance of the factory with the specified bucket name.
  ///
  ///   - Parameter bucketName: The name of the bucket to use.
  public init(bucketName: String) {
    self.bucketName = bucketName
  }

  ///   Sets up a client and returns a new `KVdbTunnelRepository` instance.
  ///
  ///   - Parameter client: The tunnel client to use.
  ///   - Returns: A new `KVdbTunnelRepository` instance.
  public func setupClient<TunnelClientType>(
    _ client: TunnelClientType
  ) -> TunnelClientRepository<Key>
    where TunnelClientType: TunnelClient, TunnelClientType.Key == Key {
    .init(client: client, bucketName: bucketName)
  }
}
