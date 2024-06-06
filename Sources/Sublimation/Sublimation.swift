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

import Foundation
import Logging

@_exported import SublimationBonjour
@_exported import SublimationNgrok

public final class Sublimation: Sendable {
  public let sublimatory: any Sublimatory

  public init(sublimatory: any Sublimatory) {
    self.sublimatory = sublimatory
  }

  public func willBoot(_ application: @Sendable @escaping () -> any Application) {
    Task {
      await self.sublimatory.willBoot(from: application)
    }
  }

  public func didBoot(_ application: @Sendable @escaping () -> any Application) {
    Task {
      await self.sublimatory.didBoot(from: application)
    }
  }

  public func shutdown(_ application: @Sendable @escaping () -> any Application) {
    Task {
      await self.sublimatory.shutdown(from: application)
    }
  }
}

#if canImport(Network)
  import Network
  import SublimationBonjour
  import SublimationCore
  import SublimationNgrok

  extension Sublimation {
    public convenience init(
      listenerParameters: NWParameters = .tcp,
      serviceType: String = BonjourSublimatory.httpTCPServiceType,
      maximumCount: Int? = nil,
      addresses: @escaping @Sendable () async -> [String],
      addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
    ) {
      self.init(
        sublimatory: BonjourSublimatory(listenerParameters: listenerParameters, serviceType: serviceType, maximumCount: maximumCount, addresses: addresses, addressFilter: addressFilter)
      )
    }

    #if os(macOS)
      public convenience init(
        listenerParameters: NWParameters = .tcp,
        serviceType: String = BonjourSublimatory.httpTCPServiceType,
        maximumCount: Int? = nil,
        addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
      ) {
        self.init(
          listenerParameters: listenerParameters,
          serviceType: serviceType,
          maximumCount: maximumCount,
          addresses: BonjourSublimatory.addressesFromHost,
          addressFilter: addressFilter
        )
      }

    #endif
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
      ngrokClient: @escaping () -> NgrokClient
    ) {
      self.init(
        sublimatory: TunnelSublimatory(
          ngrokPath: ngrokPath, bucketName: bucketName, key: key, ngrokClient: ngrokClient
        )
      )
    }
  }
#endif
