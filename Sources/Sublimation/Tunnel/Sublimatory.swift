


public protocol Sublimatory : Sendable {
  func willBoot(from application: @escaping @Sendable () -> any Application) async
  func didBoot(from application: @escaping @Sendable () -> any Application) async
  func shutdown(from application: @escaping @Sendable () -> any Application) async
}

extension Sublimatory {
  public func didBoot(from application: @escaping @Sendable () -> any Application) async {}
  public func shutdown(from application: @escaping @Sendable () -> any Application) async {}
}

