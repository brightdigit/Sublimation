public struct NullAuthorizationManager<AuthorizationType>: AuthorizationManager {
  public func fetch() async throws -> AuthorizationType? {
    nil
  }

  public typealias AuthorizationType = AuthorizationType

  public init() {}
}
