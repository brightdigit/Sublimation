//
//  Untitled.swift
//  SublimationBonjour
//
//  Created by Leo Dion on 8/23/24.
//


public struct URLDefaultConfiguration {
  public init(isSecure: Bool = false, port: Int = 8080) {
    self.isSecure = isSecure
    self.port = port
  }
  public let isSecure: Bool
  public let port: Int
}
