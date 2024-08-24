//
//  Untitled.swift
//  SublimationBonjour
//
//  Created by Leo Dion on 8/23/24.
//



/// Default Configuration for URLs.
/// 
/// If the ``BindingConfiguration`` is missing properties such as
/// ``BindingConfiguration/port`` or ``BindingConfiguration/isSecure``
/// ``BonjourClient`` using these settings as fallback.
public struct URLDefaultConfiguration {
  
  /// Create the default configuration.
  /// - Parameters:
  ///   - isSecure: Whether https or http
  ///   - port: HTTP Server port
  public init(isSecure: Bool = false, port: Int = 8080) {
    self.isSecure = isSecure
    self.port = port
  }
  
  /// Whether https or http
  public let isSecure: Bool
  
  /// Server port number.
  public let port: Int
}
