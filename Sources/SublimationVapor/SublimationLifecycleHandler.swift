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
import Vapor
import Network


extension HTTPServer.Configuration {
  public var addressDescription: String {
    let scheme = self.tlsConfiguration == nil ? "http" : "https"
    let addressDescription: String
    switch self.address {
    case .hostname(let originalHostName, let port):
      let actualHostName : String
      let originalHostName = originalHostName ?? self.hostname
      if originalHostName == "127.0.0.1" {
        dump(Host.current())
        actualHostName = Host.current().addresses.first(where: { address in
          guard address != originalHostName else {
            return false
          }
          return !address.contains(":")
        }) ?? originalHostName
      } else {
        actualHostName = originalHostName
      }
      print(actualHostName)
        return "\(scheme)://\(actualHostName):\(port ?? self.port)"
    case .unixDomainSocket(let socketPath):
      return "\(scheme)+unix: \(socketPath)"
    }
    
    
  }
}

public final class SublimationLifecycleHandler: LifecycleHandler {
  public init() {
  }
  
  var listenerQ : NWListener?
  func start(addressDescription: String) -> NWListener? {
      print("listener will start")
    
    guard let listener = try? NWListener(using: .tcp) else { return nil }
      listener.stateUpdateHandler = { newState in
          print("listener did change state, new: \(newState)")
      }
      listener.newConnectionHandler = { connection in
          connection.cancel()
      }
    let txtRecord : NWTXTRecord = .init([
      "Sublimation" : addressDescription
    ])
    
    var service = NWListener.Service(type: "_http._tcp", txtRecord: txtRecord.data)
    service.txtRecordObject =  txtRecord
    
    listener.service = service
    listener.serviceRegistrationUpdateHandler = { change in
      
        dump(change)
    }
    listener.start(queue: .global(qos: .default))
      return listener
  }
  
  func stop(listener: NWListener) {
      print("listener will stop")
      listener.stateUpdateHandler = nil
      listener.cancel()
  }
  
  public func willBoot(_ application: Application) throws {
    self.listenerQ = self.start(addressDescription: application.http.server.configuration.addressDescription)
  }
  
  public func shutdown(_ application: Application) {
    if let listenerQ = self.listenerQ {
      self.stop(listener: listenerQ)
    }
    self.listenerQ = nil
  }
}
