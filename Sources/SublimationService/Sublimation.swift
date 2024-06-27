//
//  Sublimation.swift
//  
//
//  Created by Leo Dion on 6/25/24.
//

import ServiceLifecycle
import Sublimation
import SublimationCore

extension Sublimation : Service, Serviceable {
  public static func withGracefulShutdownHandler<T>(operation: () async throws -> T, onGracefulShutdown handler: @escaping () -> Void) async rethrows -> T {
    try await ServiceLifecycle.withGracefulShutdownHandler(operation: operation, onGracefulShutdown: handler)
  }
  

}
