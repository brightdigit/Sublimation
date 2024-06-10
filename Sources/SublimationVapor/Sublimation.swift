//
//  Sublimation.swift
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

import NIOCore
import OpenAPIAsyncHTTPClient
import Sublimation
import SublimationTunnel
import Ngrokit

import Vapor
import SublimationKVdb

extension KVdbTunnelClient : TunnelClient {
  
}

extension Sublimation: LifecycleHandler {
  public func willBoot(_ application: Vapor.Application) throws {
    Task {
      self.willBoot { application }
    }
  }

  public func didBoot(_ application: Vapor.Application) throws {
    Task {
      self.didBoot { application }
    }
  }

  public func shutdown(_ application: Vapor.Application) {
    Task {
      self.shutdown { application }
    }
  }
}


#if os(macOS)
  extension TunnelSublimatory {
    ///     Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    ///     - Parameters:
    ///       - ngrokPath: The path to the Ngrok executable.
    ///       - bucketName: The name of the bucket for the tunnel repository.
    ///       - key: The key for the tunnel repository.
    ///
    ///     - Note: This initializer is only available on macOS.
    ///
    ///     - SeeAlso: `KVdbTunnelRepositoryFactory`
    ///     - SeeAlso: `NgrokCLIAPIServerFactory`
    public init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key,
      isConnectionRefused: @escaping (ClientError) -> Bool,
      ngrokClient: @escaping () -> NgrokClient
    ) where WritableTunnelRepositoryFactoryType == TunnelBucketRepositoryFactory<Key>,
        TunnelServerFactoryType == NgrokCLIAPIServerFactory<ProcessableProcess>,
      WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key == Key {
        
        
        
        
        
        
        
        
        
      self.init(
        factory: NgrokCLIAPIServerFactory(ngrokPath: ngrokPath, ngrokClient: ngrokClient),
        repoFactory: TunnelBucketRepositoryFactory(bucketName: bucketName),
        key: key, 
        repoClientFactory: { application in
          KVdbTunnelClient(
    keyType: WritableTunnelRepositoryFactoryType.TunnelRepositoryType.Key.self,
    get: {
      try await application().get(from: $0)
    }, post: {
      try await application().post(to: $0, body: $1)
    }
  )
        },
        isConnectionRefused: isConnectionRefused
      )
    }
  }
#endif


#if os(macOS)
  extension TunnelSublimatory {
    ///     Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    ///     - Parameters:
    ///       - ngrokPath: The path to the Ngrok executable.
    ///       - bucketName: The name of the bucket for the tunnel repository.
    ///       - key: The key for the tunnel repository.
    ///
    ///     - Note: This initializer is only available on macOS.
    ///
    ///     - SeeAlso: `KVdbTunnelRepositoryFactory`
    ///     - SeeAlso: `NgrokCLIAPIServerFactory`
    public init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key,
      timeout: TimeAmount = .seconds(1)
    ) where   TunnelServerFactoryType == NgrokCLIAPIServerFactory<ProcessableProcess>,
      WritableTunnelRepositoryFactoryType == TunnelBucketRepositoryFactory<Key> {
        
        self.init(
          ngrokPath: ngrokPath,
          bucketName: bucketName,
          key: key,
          isConnectionRefused: {$0.isConnectionRefused},
          ngrokClient: {
        NgrokClient(
          transport: AsyncHTTPClientTransport(configuration: .init(timeout: timeout))
        )
      })
    }
  }

  extension Sublimation {
    public convenience init(
      ngrokPath: String,
      bucketName: String,
      key: some Any,
      timeout: TimeAmount = .seconds(1)
    ) {
      let tunnelSublimatory = TunnelSublimatory(
        ngrokPath: ngrokPath,
        bucketName: bucketName,
        key: key,
        timeout: timeout
      )
      self.init(sublimatory: tunnelSublimatory)
    }
  }

#endif


#if os(macOS)
  extension Sublimation {
    ///     Initializes the Sublimation lifecycle handler with default values for macOS.
    ///
    ///     - Parameters:
    ///       - ngrokPath: The path to the Ngrok executable.
    ///       - bucketName: The name of the bucket for the tunnel repository.
    ///       - key: The key for the tunnel repository.
    ///
    ///     - Note: This initializer is only available on macOS.
    ///
    ///     - SeeAlso: `KVdbTunnelRepositoryFactory`
    ///     - SeeAlso: `NgrokCLIAPIServerFactory`
    public convenience init(
      ngrokPath: String,
      bucketName: String,
      key: some Any,
      isConnectionRefused: @escaping (ClientError) -> Bool,
      ngrokClient: @escaping () -> NgrokClient
      
    ) {
      
      self.init(
        sublimatory: TunnelSublimatory(
          ngrokPath: ngrokPath,
          bucketName: bucketName,
          key: key,
          isConnectionRefused: isConnectionRefused,
          ngrokClient: ngrokClient
          
        )
      )
    }
  }
#endif
