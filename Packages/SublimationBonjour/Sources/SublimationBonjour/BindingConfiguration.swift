//
//  Untitled.swift
//  SublimationBonjour
//
//  Created by Leo Dion on 8/23/24.
//

extension BindingConfiguration {
  
  /// Information to advertise how to connect to the server.
  ///
  /// ```
  /// let bindingConfiguration = BindingConfiguration(
  ///   host: ["Leo's-Mac.local", "192.168.1.10"],
  ///   port: 8080
  ///   isSecure: false
  /// )
  /// let bonjour = BonjourSublimatory(
  ///   bindingConfiguration: bindingConfiguration,
  ///   logger: app.logger
  /// )
  /// let sublimation = Sublimation(sublimatory : bonjour)
  /// ```
  ///
  /// - Parameters:
  ///   - hosts: List of host names and ip addresses.
  ///   - port: The port number of the server.
  ///   - isSecure: Whether to use https or http.
  ///
  public init (hosts: [String], port: Int = 8080, isSecure: Bool = false) {
    self.init()
    self.hosts = hosts
    self.isSecure = isSecure
    self.port = .init(port)
  }
}
