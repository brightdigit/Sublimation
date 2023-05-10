import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol Service<SessionType>: ServiceProtocol {
  typealias SessionAuthenticationManager =
    AuthorizationManager<SessionType.AuthorizationType>
  associatedtype SessionType: Session
    where SessionType.ResponseType.DataType == API.ResponseDataType
  var authorizationManager: any SessionAuthenticationManager { get }
  var session: SessionType { get }
  var api: API { get }
}

extension Service {
  public func request<RequestType>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
    where RequestType: ServiceCall, RequestType.API == Self.API,
    SessionType.RequestDataType == Self.API.RequestDataType {
    let response = try await session.data(
      request: request,
      withBaseURL: api.baseURLComponents,
      withHeaders: api.headers,
      authorizationManager: authorizationManager,
      usingEncoder: request.resolveEncoder(with: api)
    )

    guard request.isValidStatusCode(response.statusCode) else {
      throw RequestError.invalidStatusCode(response.statusCode)
    }

    return try request.resolveDecoder(with: api).decodeContent(
      RequestType.SuccessType.self,
      from: response.data
    )
  }
}
