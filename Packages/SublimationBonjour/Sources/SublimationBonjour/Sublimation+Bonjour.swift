//
//  Sublimation+Bonjour.swift
//  SublimationBonjour
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

#if canImport(Network)
  public import Network
  public import Sublimation

  extension Sublimation {
    /// Initializes a `Sublimation` instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - listenerParameters: The network parameters to use for the listener. Default is `.tcp`.
    ///   - serviceType: The Bonjour service type. Default is `BonjourSublimatory.httpTCPServiceType`.
    ///   - maximumCount: The maximum number of connections. Default is `nil`.
    ///   - addresses: A closure that asynchronously returns a list of addresses.
    ///   - addressFilter: A closure that filters the addresses. Default is `String.isIPv4NotLocalhost(_:)`.
    public convenience init(
      listenerParameters: NWParameters = .tcp,
      serviceType: String = BonjourSublimatory.defaultHttpTCPServiceType,
      maximumCount: Int? = nil,
      addresses: @escaping @Sendable () async -> [String],
      addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
    ) {
      let sublimatory = BonjourSublimatory(serverConfiguration: listenerParameters, name: serviceType, type: serviceType)
      
        
//      let sublimatory = BonjourSublimatory(
//        listenerParameters: listenerParameters,
//        serviceType: serviceType,
//        maximumCount: maximumCount,
//        addresses: addresses,
//        addressFilter: addressFilter
//      )
      self.init(sublimatory: sublimatory)
    }

    #if os(macOS)
      /// Initializes a `Sublimation` instance with the provided parameters on macOS.
      ///
      /// - Parameters:
      ///   - listenerParameters: The network parameters to use for the listener. Default is `.tcp`.
      ///   - serviceType: The Bonjour service type. Default is `BonjourSublimatory.httpTCPServiceType`.
      ///   - maximumCount: The maximum number of connections. Default is `nil`.
      ///   - addressFilter: A closure that filters the addresses.
      ///   Default is `String.isIPv4NotLocalhost(_:)`.
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
