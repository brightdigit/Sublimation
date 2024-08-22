//
//  BonjourSublimatory.swift
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

  internal import Foundation

  public import Network

  public import SublimationCore

  public import Logging

public struct BonjourSublimatory: Sublimatory {
  public init(
    bindingConfiguration: BindingConfiguration,
    logger: Logger,
    listener: NWListener,
    name: String = Self.defaultName,
    type: String = Self.defaultHttpTCPServiceType,
    listenerQueue: DispatchQueue = .global(),
    connectionQueue: DispatchQueue = .global()
  ) {
    self.bindingConfiguration = bindingConfiguration
    self.logger = logger
    self.listener = listener
    self.name = name
    self.type = type
    self.listenerQueue = listenerQueue
    self.connectionQueue = connectionQueue
  }
  

  
    public init(
      bindingConfiguration: BindingConfiguration,
      logger: Logger,
      parameters: NWParameters = Self.defaultParameters,
      name: String = Self.defaultName,
      type: String = Self.defaultHttpTCPServiceType,
      listenerQueue: DispatchQueue = .global(),
      connectionQueue: DispatchQueue = .global()
    ) throws {
      let listener = try NWListener(using: parameters)
      self.init(
        bindingConfiguration: bindingConfiguration,
        logger: logger,
        listener: listener,
        name: name,
        type: type,
        listenerQueue: listenerQueue,
        connectionQueue: connectionQueue
      )
    }
  
  let bindingConfiguration: BindingConfiguration
  let logger: Logger
  let listener: NWListener
    let name: String
    let type: String
    let listenerQueue: DispatchQueue
    let connectionQueue: DispatchQueue
    public static let defaultName = "Sublimation"
    public static let defaultHttpTCPServiceType = "_sublimation._tcp"
    public static let defaultParameters: NWParameters = .tcp

    //    @available(*, unavailable, message: "Temporary Code for pulling ipaddresses.")
    //    static func getAllIPAddresses() -> [String: [String]] {
    //      var addresses: [String: [String]] = [:]
    //
    //      let monitor = NWPathMonitor()
    //      let queue = DispatchQueue.global(qos: .background)
    //
    //      monitor.pathUpdateHandler = { path in
    //        for interface in path.availableInterfaces {
    //          var interfaceAddresses: [String] = []
    //          let endpoint = NWEndpoint.Host(interface.debugDescription)
    //          let parameters = NWParameters.tcp
    //          parameters.requiredInterface = interface
    //
    //          let connection = NWConnection(host: endpoint, port: 80, using: parameters)
    //          connection.stateUpdateHandler = { state in
    //            if case .ready = state {
    //              if let localEndpoint = connection.currentPath?.localEndpoint {
    //                switch localEndpoint {
    //                case let .hostPort(host, _):
    //                  interfaceAddresses.append(host.debugDescription)
    //                default:
    //                  break
    //                }
    //              }
    //              addresses[interface.debugDescription] = interfaceAddresses
    //            }
    //          }
    //          connection.start(queue: queue)
    //        }
    //        monitor.cancel()
    //      }
    //
    //      monitor.start(queue: queue)
    //
    //      // Wait for a short period to gather the results
    //      sleep(2)
    //
    //      return addresses
    //    }

    public func shutdown() {
      listener.cancel()
    }
    public func run() async throws {
      let data = try self.bindingConfiguration.serializedData()
      let txtRecordValues = data.base64EncodedString().splitByMaxLength(199)
      let dictionary = txtRecordValues.enumerated()
        .reduce(into: [String: String]()) { result, value in
          result["Sublimation_\(value.offset)"] = String(value.element)
        }
      let txtRecord = NWTXTRecord(dictionary)
      assert(listener.service == nil)
      listener.service = .init(name: name, type: type, txtRecord: txtRecord)

      listener.newConnectionHandler = { connection in
        connection.stateUpdateHandler = { state in
          switch state { case .waiting(let error):

            self.logger.warning("Connection Waiting error: \(error)")

            case .ready:
              self.logger.debug("Connection Ready")
              self.logger.debug("Sending data \(data.count) bytes")
              connection.send(
                content: data,
                completion: .contentProcessed { error in
                  if let error { self.logger.warning("Connection Send error: \(error)") }
                  connection.cancel()
                }
              )
            case .failed(let error): self.logger.error("Connection Failure: \(error)")

            default: self.logger.debug("Connection state updated: \(state)")
          }
        }
        connection.start(queue: connectionQueue)
      }

      listener.start(queue: listenerQueue)

      return try await withCheckedThrowingContinuation { continuation in
        listener.stateUpdateHandler = { state in
          switch state { case .waiting(let error):
            self.logger.warning("Listener Waiting error: \(error)")
            continuation.resume(throwing: error)

            case .failed(let error):
              self.logger.error("Listener Failure: \(error)")
              continuation.resume(throwing: error)
            case .cancelled: continuation.resume()
            default: self.logger.debug("Listener state updated: \(state)")
          }
        }
      }
    }
  }
#endif
