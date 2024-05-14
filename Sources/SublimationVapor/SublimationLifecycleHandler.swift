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

private actor BonjourListener {

  
  func stop () {
    assert(self.listener != nil)
      listener?.stateUpdateHandler = nil
      listener?.cancel()
    listener = nil
  }
  
  var listener: NWListener?
}

extension BonjourListener {
  func start(isTLS: Bool, port: Int) {
    #warning("Add Logger")
    guard let listener = try? NWListener(using: .tcp) else { return  }
    #warning("Store State")
      listener.stateUpdateHandler = { newState in
          print("listener did change state, new: \(newState)")
      }
      listener.newConnectionHandler = { connection in
          connection.cancel()
      }
#warning("Refactor Dictionary")
    var dictionary = [
      "Sublimation_TLS": isTLS ? "true" : "false",  "Sublimation_Port": port.description
    ]
    for address in Host.current().addresses {
#warning("Add Filter options")
      guard !(["127.0.0.1", "::1", "localhost"].contains(address)) else {
        continue
      }
      guard !address.contains(":") else {
        continue
      }
      let index = dictionary.count - 2
      #warning("Max count")
      dictionary["Sublimation_Address_\(index)"] = address
    }
    
    let txtRecord : NWTXTRecord = .init(dictionary)
    dump(txtRecord)
    var service = NWListener.Service(type: "_http._tcp", txtRecord: txtRecord.data)
    service.txtRecordObject =  txtRecord
    
    listener.service = service
    listener.serviceRegistrationUpdateHandler = { change in
      
        dump(change)
    }
    listener.start(queue: .global(qos: .default))
    self.listener = listener
  }
}

public final class SublimationLifecycleHandler: LifecycleHandler {
  public init() {
    listenerQ = BonjourListener()
  }
  
  private let listenerQ : BonjourListener


  
  public func willBoot(_ application: Application) throws {
    Task {
      await self.listenerQ.start(
        isTLS: application.http.server.configuration.tlsConfiguration != nil,
        port: application.http.server.configuration.port)
    }
  }
  
  public func shutdown(_ application: Application) {
    
      Task {
        await listenerQ.stop()
      }
    
  }
}
