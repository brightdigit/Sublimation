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
  associatedtype SessionType: Session where SessionType.ResponseType.DataType == API.ResponseDataType
// var baseURLComponents: URLComponents { get }
  var authorizationManager: any SessionAuthenticationManager { get }
  var session: SessionType { get }
//  var headers: [String: String] { get }
//  var encoder: any Encoder<SessionType.ResponseType.DataType> { get }
//  var decoder: any Decoder<SessionType.ResponseType.DataType> { get }
}

extension Service {
  public func request<RequestType>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
  where RequestType: ServiceCall, RequestType.API == Self.API, SessionType.RequestDataType == Self.API.RequestDataType {
      
    
    let response = try await session.data(
      request: request,
      withBaseURL: API.baseURLComponents,
      withHeaders: API.headers,
      authorizationManager: authorizationManager,
      usingEncoder: request.resolveEncoder()
    )

    guard request.isValidStatusCode(response.statusCode) else {
      throw RequestError.invalidStatusCode(response.statusCode)
    }

    return try request.resolveDecoder().decodeContent(
      RequestType.SuccessType.self,
      from: response.data
    )
  }
}
