import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol AuthorizationManager<AuthorizationType> {
  associatedtype AuthorizationType
  func fetch() async throws -> AuthorizationType?
}

public protocol Service<SessionType>: ServiceProtocol {
  typealias SessionAuthenticationManager =
    AuthorizationManager<SessionType.AuthorizationType>
  associatedtype SessionType: Session
  var baseURLComponents: URLComponents { get }
  var authorizationManager: any SessionAuthenticationManager { get }
  var session: SessionType { get }
  var headers: [String: String] { get }
  var coder: any Coder<SessionType.ResponseType.DataType> { get }
}

extension Service {
  public func request<RequestType>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
    where RequestType: ServiceCall {
    let response = try await session.data(
      request: request,
      withBaseURL: baseURLComponents,
      withHeaders: headers,
      authorizationManager: authorizationManager,
      usingEncoder: coder
    )

    guard request.isValidStatusCode(response.statusCode) else {
      throw RequestError.invalidStatusCode(response.statusCode)
    }

    return try coder.decodeContent(
      RequestType.SuccessType.self,
      from: response.data
    )
  }
}
