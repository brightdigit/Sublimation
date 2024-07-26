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

#if canImport(Network)

  internal import Foundation

  internal import Network

public import SublimationCore

public struct BonjourSublimatory : Sublimatory {
  
  public  init(
      serverConfiguration: BindingConfiguration, name: String = Self.defaultName,
      type: String = Self.defaultHttpTCPServiceType
    ) {
      self.name = name
      self.type = type
      self.serverConfiguration = serverConfiguration
    }

    let name: String
    let type: String
    let serverConfiguration: BindingConfiguration

  public static let defaultName = "Sublimation"
    public static let defaultHttpTCPServiceType = "_sublimation._tcp"

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
      // listener cancel
  }
  
  public func run() async throws {
      let data = try self.serverConfiguration.serializedData()
      let listener = try NWListener(using: .tcp)      
      let txtRecordValues = data.base64EncodedString().splitByMaxLength(199)
      let dictionary = txtRecordValues.enumerated().reduce(into: [String: String]()) {
        result, value in
        result["Sublimation_\(value.offset)"] = String(value.element)
      }
      let txtRecord = NWTXTRecord(dictionary)
      listener.service = .init(name: name, type: type, txtRecord: txtRecord)

      listener.newConnectionHandler = { connection in
        connection.stateUpdateHandler = { state in
          switch state {
          case let .waiting(error):

            print("Connection Waiting error: \(error)")

          case .ready:
            print("Connection Ready ")
            print("Sending \(data.count) bytes")
            connection.send(
              content: data,
              completion: .contentProcessed { error in
                print("content sent")
                dump(error)
                connection.cancel()
              }
            )
          case let .failed(error):
            print("Connection Failure: \(error)")

          default:
            print("Connection state updated: \(state)")
          }
        }
        connection.start(queue: .global())
      }

      listener.start(queue: .global())

      return try await withCheckedThrowingContinuation { continuation in
        listener.stateUpdateHandler = { state in
          switch state {
          case let .waiting(error):

            print("Listener Waiting error: \(error)")
            continuation.resume(throwing: error)

          case let .failed(error):
            print("Listener Failure: \(error)")
            continuation.resume(throwing: error)
          case .cancelled:
            continuation.resume()
          default:
            print("Listener state updated: \(state)")
          }
        }
      }
    }
  }
#endif
