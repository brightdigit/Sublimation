//
//  BonjourSublimatory.swift
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

#if canImport(Network)
  import Foundation
  import Logging
  import Network
  import SublimationCore

  public actor BonjourSublimatory: Sublimatory {
    public static let httpTCPServiceType = "_http._tcp"
    private let serviceType: String
    private let maximumCount: Int?
    private let addresses: @Sendable () async -> [String]
    // TODO: Create a Filter Builder
    private let addressFilter: @Sendable (String) -> Bool
    private let listenerParameters: NWParameters
    private nonisolated(unsafe) var logger: Logger?
    private var listener: NWListener? {
      didSet {
        guard let listener else {
          return
        }

        listener.stateUpdateHandler = { newState in
          Task {
            await self.updateState(newState)
          }
        }
        listener.newConnectionHandler = { connection in
          self.logger?.debug("Cancelling connection: \(connection.debugDescription)")
          connection.cancel()
        }

        listener.serviceRegistrationUpdateHandler = { _ in
          // TODO: put this in an AsyncStream
        }
      }
    }

    internal private(set) var state: NWListener.State?

    public init(
      listenerParameters: NWParameters = .tcp,
      serviceType: String = httpTCPServiceType,
      maximumCount: Int? = nil,
      addresses: @escaping @Sendable () async -> [String],
      addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
    ) {
      self.listenerParameters = listenerParameters
      self.serviceType = serviceType
      self.maximumCount = maximumCount
      self.addressFilter = addressFilter
      self.addresses = addresses
    }

    #if os(macOS)
      public init(
        listenerParameters: NWParameters = .tcp,
        serviceType: String = httpTCPServiceType,
        maximumCount: Int? = nil,
        addressFilter: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:)
      ) {
        self.init(
          listenerParameters: listenerParameters,
          serviceType: serviceType,
          maximumCount: maximumCount,
          addresses: Self.addressesFromHost,
          addressFilter: addressFilter
        )
      }

      @Sendable
      public static func addressesFromHost() -> [String] {
        Host.current().addresses
      }
    #endif

    internal func stop() {
      assert(listener != nil)
      listener?.stateUpdateHandler = nil
      listener?.cancel()
      listener = nil
    }

    private func updateState(_ newState: NWListener.State) {
      state = newState
      logger?.debug("Listener changed state to \(newState.debugDescription).")
    }

    public func willBoot(from application: @escaping @Sendable () -> any Application) async {
      let application = application()
      await self.start(
        isTLS: application.httpServerTLS,
        port: application.httpServerConfigurationPort,
        logger: application.logger
      )
    }

    public func shutdown(from _: @escaping @Sendable () -> any Application) async {
      self.stop()
    }
  }

  extension BonjourSublimatory {
    internal func start(
      isTLS: Bool,
      port: Int,
      logger: Logger
    ) async {
      self.logger = logger
      let addresses = await self.addresses()
      let txtRecord: NWTXTRecord = .init(
        isTLS: isTLS,
        port: port,
        maximumCount: maximumCount,
        filter: addressFilter,
        addresses: addresses
      )
      let listener: NWListener
      do {
        listener = try NWListener(
          using: listenerParameters,
          serviceType: self.serviceType,
          txtRecord: txtRecord
        )
      } catch {
        assertionFailure("Unable to create listener: \(error.localizedDescription)")
        logger.error("Unable to create listener: \(error.localizedDescription)")
        return
      }

      self.listener = listener
      listener.start(queue: .global(qos: .default))
    }
  }

#endif
