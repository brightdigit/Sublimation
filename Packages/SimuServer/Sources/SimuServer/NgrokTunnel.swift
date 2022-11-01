//
// NgrokTunnel.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Foundation
import Vapor

public struct NgrokTunnelRequest : Content {
  internal init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }
  
  public init (port: Int, proto : String = "http", name: String = "vapor-development") {
    self.init(addr: port.description, proto: proto, name: name)
  }
  
  let addr : String
  let proto : String
  let name : String
}
public struct NgrokTunnelConfiguration : Codable {
  
  let addr : URL
  let inspect : Bool
}
public struct NgrokTunnel: Codable {
  let name : String
  // swiftlint:disable:next identifier_name
  let public_url: URL
  let config : NgrokTunnelConfiguration

}
