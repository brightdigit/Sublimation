import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol AuthorizationManager<AuthorizationType> {
  associatedtype AuthorizationType
  func fetch() async throws -> AuthorizationType?
}

public struct StaticBaseAPIContainer<API : StaticBaseAPI> : BaseAPI {
  
  public var baseURLComponents: URLComponents {
    return API.baseURLComponents
  }
  public var headers: [String: String] {
  return API.headers
}
  public var encoder: any Encoder<API.RequestDataType> {
  return API.encoder
}
  public var decoder: any Decoder<API.ResponseDataType> {
  return API.decoder
}
}

public protocol Service<SessionType>: ServiceProtocol {
  typealias SessionAuthenticationManager =
    AuthorizationManager<SessionType.AuthorizationType>
  associatedtype SessionType: Session where SessionType.ResponseType.DataType == API.ResponseDataType
  var authorizationManager: any SessionAuthenticationManager { get }
  var session: SessionType { get }

  var api : API { get }
}

public protocol StaticAPIService : Service  {
  associatedtype StaticAPI : StaticBaseAPI
}

extension StaticAPIService where API == StaticBaseAPIContainer<StaticAPI> {
  public var api: API {
    return StaticBaseAPIContainer()
  }
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
      usingEncoder: request.resolveEncoder(with: self.api)
    )

    guard request.isValidStatusCode(response.statusCode) else {
      throw RequestError.invalidStatusCode(response.statusCode)
    }

    return try request.resolveDecoder(with: self.api).decodeContent(
      RequestType.SuccessType.self,
      from: response.data
    )
  }
}
