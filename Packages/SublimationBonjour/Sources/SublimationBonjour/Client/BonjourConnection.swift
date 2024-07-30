//
//  BonjourConnection.swift
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

////
////  BonjourConnection.swift
////  SublimationBonjour
////
////  Created by Leo Dion.
////  Copyright © 2024 BrightDigit.
////
////  Permission is hereby granted, free of charge, to any person
////  obtaining a copy of this software and associated documentation
////  files (the “Software”), to deal in the Software without
////  restriction, including without limitation the rights to use,
////  copy, modify, merge, publish, distribute, sublicense, and/or
////  sell copies of the Software, and to permit persons to whom the
////  Software is furnished to do so, subject to the following
////  conditions:
////
////  The above copyright notice and this permission notice shall be
////  included in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
////  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
////  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
////  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
////  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
////  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
////  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
////  OTHER DEALINGS IN THE SOFTWARE.
////
//
//#if canImport(Network)
//  internal import Foundation
//
//  internal import Network
//
//  internal actor BonjourConnection {
//    private let connection: NWConnection
//    private let client: BonjourClient
//    internal let id: UUID
//
//
//    private static func onConnection(
//      _ connection: NWConnection,
//      withID id: UUID,
//      state: NWConnection.State,
//      from client: BonjourClient
//    ) {
//      client.connection(withID: id, updatedTo: state)
//      switch state { case .ready:
//        connection.receiveMessage { content, contentContext, isComplete, error in
//          let configuration: BindingConfiguration?
//          do { configuration = try .init(content, contentContext, isComplete, error) }
//          catch {
//            client.connection(withID: id, failedWithError: error)
//            return
//          }
//
//          guard let configuration else { return }
//          #warning("Defaults should be passed to connection")
//          let urls = configuration.urls(defaultIsSecure: false, defaultPort: 8_080)
//          client.connection(withID: id, received: urls)
//        }
//        case let .waiting(error): client.connection(withID: id, failedWithError: error)
//        case let .failed(error): client.connection(withID: id, failedWithError: error)
//        case .cancelled: client.cancelledConnection(withID: id)
//        default: break
//      }
//    }
//
//    internal nonisolated func cancel() { Task { await self.completeCancel() } }
//
//    private func completeCancel() { self.connection.cancel() }
//  }
//
//  extension BonjourConnection {
//    internal init?(result: NWBrowser.Result, client: BonjourClient) {
//      guard
//        case let .service(name: name, type: type, domain: domain, interface: _) = result.endpoint
//      else { return nil }
//      let connection = NWConnection(
//        to: .service(name: name, type: type, domain: domain, interface: nil),
//        using: .tcp
//      )
//      self.init(id: .init(), connection: connection, client: client)
//      connection.start(queue: .global())
//    }
//  }
//#endif
