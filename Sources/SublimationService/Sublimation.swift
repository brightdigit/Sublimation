//
//  Sublimation.swift
//  
//
//  Created by Leo Dion on 6/25/24.
//

import ServiceLifecycle
import Sublimation
import SublimationCore

extension Sublimation : Service {
  public func initialize(from application: @escaping @Sendable () -> any Application) async throws {
    try await self.sublimatory.initialize(from: application)
  }
  public func run() async throws {
    try await self.sublimatory.run()
  }
}
