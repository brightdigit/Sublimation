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

extension String {
  @Sendable
  static func isIPv4NotLocalhost(_ address: String) -> Bool {
    guard !(["127.0.0.1", "::1", "localhost"].contains(address)) else {
      return false
    }
    guard !address.contains(":") else {
      return false
    }
    return true
  }
}

private actor BonjourListener {
  internal init(
    logger: Logger? = nil,
    maximumCount: Int? = nil,
    address: @escaping @Sendable (String) -> Bool = String.isIPv4NotLocalhost(_:),
    listener: NWListener? = nil
  ) {
    self.logger = logger
    self.maximumCount = maximumCount
    self.address = address
    self.listener = listener
  }

  var logger: Logger?
  let maximumCount: Int?
  let address: @Sendable (String) -> Bool
  var listener: NWListener?
  var state: NWListener.State?

  func stop() {
    assert(listener != nil)
    listener?.stateUpdateHandler = nil
    listener?.cancel()
    listener = nil
  }

  func updateState(_ newState: NWListener.State) {
    state = newState
    logger?.debug("Listener changed state to \(newState).")
  }
}

extension BonjourListener {
  func start(isTLS: Bool, port: Int, logger: Logger) {
    self.logger = logger
    let listener: NWListener
    do {
      listener = try NWListener(using: .tcp)
    } catch {
      logger.error("Unable to create listener: \(error.localizedDescription)")
      return
    }
    listener.stateUpdateHandler = { newState in
      Task {
        await self.updateState(newState)
      }
    }
    listener.newConnectionHandler = { connection in
      connection.cancel()
    }

    let txtRecord: NWTXTRecord = .init(isTLS: isTLS, port: port, maximumCount: maximumCount, filter: address, addresses: Host.current().addresses)
    var service = NWListener.Service(type: "_http._tcp", txtRecord: txtRecord.data)
    service.txtRecordObject = txtRecord
    listener.service = service
    listener.serviceRegistrationUpdateHandler = { change in
      logger.debug("New Change: \(change)")
    }
    listener.start(queue: .global(qos: .default))
    self.listener = listener
  }
}

public final class SublimationLifecycleHandler: LifecycleHandler {
  public init() {
    listenerQ = BonjourListener()
  }

  private let listenerQ: BonjourListener

  public func willBoot(_ application: Application) throws {
    Task {
      await self.listenerQ.start(
        isTLS: application.http.server.configuration.tlsConfiguration != nil,
        port: application.http.server.configuration.port,
        logger: application.logger
      )
    }
  }

  public func shutdown(_: Application) {
    Task {
      await listenerQ.stop()
    }
  }
}
