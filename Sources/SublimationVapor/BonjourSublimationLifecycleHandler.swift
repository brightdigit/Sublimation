//
//  SublimationLifecycleHandler.swift
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
import Network
import Sublimation
import Vapor

public protocol Sublimatory : Sendable {
  func willBoot(from application: Application) async
  func didBoot(from application: Application) async
  func shutdown(from application: Application) async
}

extension Sublimatory {
  public func didBoot(from application: Application) async {}
  public func shutdown(from application: Application) async {}
}

public final class Sublimation: LifecycleHandler {
  
  public let sublimatory : any Sublimatory
  public init(sublimatory: any Sublimatory) {
    self.sublimatory = sublimatory
  }
  
  public func willBoot(_ application: Application) throws {
    Task {
      await self.sublimatory.willBoot(from: application)
    }
  }
  
  public func didBoot(_ application: Application) throws {
    Task {
      await self.sublimatory.didBoot(from: application)
    }
  }
  
  public func shutdown(_ application: Application) {
    Task {
      await self.sublimatory.shutdown(from: application)
    }
  }
}

extension Sublimation {
  public convenience init (
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
  public convenience init (
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
