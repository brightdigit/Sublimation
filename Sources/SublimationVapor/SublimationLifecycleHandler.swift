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


public final class SublimationLifecycleHandler: LifecycleHandler {
  public init() {
  }
  
  var listenerQ : NWListener?
  func start() -> NWListener? {
      print("listener will start")
      guard let listener = try? NWListener(using: .tcp) else { return nil }
      listener.stateUpdateHandler = { newState in
          print("listener did change state, new: \(newState)")
      }
      listener.newConnectionHandler = { connection in
          connection.cancel()
      }       
    listener.service = .init(type: "_ssh._tcp")
    listener.serviceRegistrationUpdateHandler = { change in
        print(change)
    }
    listener.start(queue: .global(qos: .default))
      return listener
  }
  
  func stop(listener: NWListener) {
      print("listener will stop")
      listener.stateUpdateHandler = nil
      listener.cancel()
  }
  
  func startStop() {
      if let listener = self.listenerQ {
          self.listenerQ = nil
          self.stop(listener: listener)
      } else {
          self.listenerQ = self.start()
      }
  }
  
  public func willBoot(_ application: Application) throws {
    self.listenerQ = self.start()
  }
  
  public func shutdown(_ application: Application) {
    if let listenerQ = self.listenerQ {
      self.stop(listener: listenerQ)
    }
    self.listenerQ = nil
  }
}
