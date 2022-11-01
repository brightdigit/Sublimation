//
// NgrokTunnel.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Foundation

public struct NgrokTunnelRequest : Codable {
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
  public let name : String
  // swiftlint:disable:next identifier_name
  public let public_url: URL
  public let config : NgrokTunnelConfiguration

}
