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
  import NIOCore
  import NIOPosix
  import NIOTransportServices
  import SublimationCore

  extension ServerConfiguration {
    init(isSecure: Bool? = nil, port: Int? = nil, hosts: [String] = []) {
      self.init()
      self.isSecure = isSecure ?? false
      self.port = port.map(UInt32.init) ?? 8_080
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

    public func run() async throws {
      let bootstrap = NIOTSListenerBootstrap(group: NIOTSEventLoopGroup.singleton)
        .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)

      let addresses = await self.addresses()

      let configuration = ServerConfiguration(isSecure: false, port: 8_080, hosts: addresses)

      let channel = try await bootstrap.bind(endpoint: .service(name: "Sublimation", type: Self.httpTCPServiceType, domain: "local.", interface: nil)) { channel in
        channel.eventLoop.makeCompletedFuture {
          try NIOAsyncChannel(
            wrappingChannelSynchronously: channel,
            configuration: .init(
              isOutboundHalfClosureEnabled: true,
              inboundType: ByteBuffer.self,
              outboundType: ByteBuffer.self
            )
          )
        }
      }

      // bootstrap.bind(endpoint: .service(name: "Sublimation", type: Self.httpTCPServiceType, domain: "local.", interface: nil))

      await withDiscardingTaskGroup { group in
        do {
          try await channel.executeThenClose { clients in
            // dump(inbound)

            for try await childChannel in clients {
              dump(childChannel)
              group.addTask {
                do {
                  try await childChannel.executeThenClose { _, outbound in
                    try await outbound.write(.init(data: configuration.serializedData()))
                  }
                } catch {
                  dump(error)
                }
                // print(String(decoding: data, as: UTF8.self))
              }
              // outbound.write(data)
            }
          }
        } catch {
          print("Waiting on child channel: \(error)")
        }
      }

      print("Closing out")
      // let channel = try await bootstrap.withNWListener(listener)
      // try await channel.closeFuture.get()
    }
  }

#endif
