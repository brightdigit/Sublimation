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
  import NIOTransportServices
import NIOCore
import NIOPosix

extension ServerConfiguration {
  init (isSecure: Bool? = nil, port: Int? = nil, hosts: [String] = []) {
    self.init()
    self.isSecure = isSecure ?? false
    self.port = port.map(UInt32.init) ?? 8080
    self.hosts = hosts
  }
}

  public actor BonjourSublimatory: Sublimatory {
    public static let httpTCPServiceType = "_http._tcp"
    private let serviceType: String
    private let maximumCount: Int?
    private let addresses: @Sendable () async -> [String]
    // TODO: Create a Filter Builder
    private let addressFilter: @Sendable (String) -> Bool
    private let listenerParameters: NWParameters
    private nonisolated(unsafe) var logger: Logger?
    @available(*, deprecated)
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

    @available(*, deprecated)
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

    @available(*, deprecated)
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
    
    nonisolated public func shutdown() {
      Task {
        await self.stop()
      }
    }
    
    public func initialize(from application: @escaping () -> any Application) async throws {
      let application = application()
      try await self.listener(
        application.httpServerTLS,
        application.httpServerConfigurationPort,
        application.logger
      )
    }
    
    public func run() async throws {
      let bootstrap = NIOTSListenerBootstrap(group: NIOTSEventLoopGroup.singleton)
        .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)
      
      
      let addresses = await self.addresses()

      let configuration = ServerConfiguration(isSecure: false, port: 8080, hosts: addresses)
      
      
      let channel = try await bootstrap.bind(endpoint: .service(name: "Sublimation", type: Self.httpTCPServiceType, domain: "local.", interface: nil)) { channel in
        return channel.eventLoop.makeCompletedFuture{
          return try NIOAsyncChannel(
            wrappingChannelSynchronously: channel,
            configuration: .init(
              isOutboundHalfClosureEnabled: true,
              inboundType: ByteBuffer.self,
              outboundType: ByteBuffer.self
            )
          )
        }
      }
      
       //bootstrap.bind(endpoint: .service(name: "Sublimation", type: Self.httpTCPServiceType, domain: "local.", interface: nil))
      
      await withDiscardingTaskGroup { group in
        do {
          
          try await channel.executeThenClose { clients in
            //dump(inbound)
            
            for try await childChannel in clients {
              dump(childChannel)
              group.addTask {
                do {
                  try await childChannel.executeThenClose { inbound, outbound in
                    try await outbound.write(.init(data: configuration.serializedData()))
                  }
                } catch {
                  dump(error)
                }
                //print(String(decoding: data, as: UTF8.self))
              }
              //outbound.write(data)
              
            }
          }
        } catch {
          print("Waiting on child channel: \(error)")
        }
      }
      
      print("Closing out")
      //let channel = try await bootstrap.withNWListener(listener)
      //try await channel.closeFuture.get()
    }
  }

  extension BonjourSublimatory {
    fileprivate func listener(from application: @escaping @Sendable () -> any Application) async throws -> NWListener  {
      let application = application()
      return try await self.listener(
        application.httpServerTLS,
        application.httpServerConfigurationPort,
        application.logger
      )
    }
    fileprivate func listener(_ isTLS: Bool, _ port: Int, _ logger: Logger) async throws -> NWListener {
      let addresses = await self.addresses()
      let txtRecord: NWTXTRecord = .init(
        isTLS: isTLS,
        port: port,
        maximumCount: maximumCount,
        addresses: addresses,
        filter: addressFilter
      )
      let listener: NWListener
      
        listener = try NWListener(
          using: listenerParameters,
          serviceType: self.serviceType,
          txtRecord: txtRecord
        )
      
      self.listener = listener
      //listener.start(queue: .global(qos: .default))
      return listener
    }
    
    internal func start(from application: @escaping @Sendable () -> any Application
    ) async {
      
      let logger =  application().logger
      do {
        let listener = try await listener(from: application)
        listener.start(queue: .global())
      } catch {
        assertionFailure("Unable to create listener: \(error.localizedDescription)")
        logger.error("Unable to create listener: \(error.localizedDescription)")
        return
      }
    }
    
    internal func start(
      isTLS: Bool,
      port: Int,
      logger: Logger
    ) async {
      self.logger = logger
      do {
        let listener  = try await listener(isTLS, port, logger)
        
        listener.start(queue: .global())
      } catch {
        assertionFailure("Unable to create listener: \(error.localizedDescription)")
        logger.error("Unable to create listener: \(error.localizedDescription)")
        return
      }
    }
  }

#endif
