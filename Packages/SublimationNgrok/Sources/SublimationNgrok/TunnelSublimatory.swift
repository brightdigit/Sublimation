//
//  TunnelSublimatory.swift
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
public import Ngrokit
public import OpenAPIRuntime
public import SublimationCore
import SublimationKVdb
public import SublimationTunnel

#if os(macOS)
  // periphery:ignore
  /// Adds support for **ngrok** and **kvDB**
  extension TunnelSublimatory {
    /// Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    /// - Parameters:
    ///   - ngrokPath: The path to the Ngrok executable.
    ///   - bucketName: The name of the bucket for the tunnel repository.
    ///   - key: The key for the tunnel repository.
    ///   - application: Server Application for setup.
    ///   - isConnectionRefused: Whether the `ClientError` is connection refused.
    ///   - ngrokClient: Returns a new `NgrokClient`.
    ///
    /// - Note: This initializer is only available on macOS.
    ///
    /// - SeeAlso: `KVdbTunnelRepositoryFactory`
    /// - SeeAlso: `NgrokCLIAPIServerFactory`
    ///
    public init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key,
      application: @Sendable @escaping () -> any Application,
      isConnectionRefused: @escaping @Sendable (ClientError) -> Bool,
      ngrokClient: @escaping @Sendable () -> NgrokClient
    ) async
    where
      WritableTunnelRepositoryFactoryType == TunnelBucketRepositoryFactory<Key>,
      TunnelServerFactoryType == NgrokCLIAPIServerFactory<ProcessableProcess>,
      WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key == Key
    {
      await self.init(
        factory: NgrokCLIAPIServerFactory(ngrokPath: ngrokPath, ngrokClient: ngrokClient),
        repoFactory: TunnelBucketRepositoryFactory(bucketName: bucketName),
        key: key,
        application: application,
        repoClientFactory: { application in
          KVdbTunnelClient(
            keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self,
            get: { try await application().get(from: $0) },
            post: { try await application().post(to: $0, body: $1) }
          )
        },
        isConnectionRefused: isConnectionRefused
      )
    }

    /// Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    /// - Parameters:
    ///   - ngrokPath: The path to the Ngrok executable.
    ///   - bucketName: The name of the bucket for the tunnel repository.
    ///   - key: The key for the tunnel repository.
    ///   - application: Server Application for setup.
    ///   - isConnectionRefused: Whether the `ClientError` is connection refused.
    ///   - transport: `ClientTransport` to use for the `NgrokClient`
    ///   - serverURL: `URL` to `NgrokClient`.
    ///
    /// - Note: This initializer is only available on macOS.
    ///
    /// - SeeAlso: `KVdbTunnelRepositoryFactory`
    /// - SeeAlso: `NgrokCLIAPIServerFactory`
    ///
    public init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key,
      application: @Sendable @escaping () -> any Application,
      isConnectionRefused: @escaping @Sendable (ClientError) -> Bool,
      transport: any ClientTransport,
      serverURL: URL? = nil
    ) async
    where
      TunnelServerFactoryType == NgrokCLIAPIServerFactory<ProcessableProcess>,
      WritableTunnelRepositoryFactoryType == TunnelBucketRepositoryFactory<Key>
    {
      await self.init(
        ngrokPath: ngrokPath,
        bucketName: bucketName,
        key: key,
        application: application,
        isConnectionRefused: isConnectionRefused,
        ngrokClient: { NgrokClient(transport: transport, serverURL: serverURL) }
      )
    }
  }

#endif
