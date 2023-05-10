import Foundation
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif


public struct NullAuthorizationManager<AuthorizationType> : AuthorizationManager {
  public func fetch() async throws -> AuthorizationType? {
    return nil
  }
  
  public typealias AuthorizationType = AuthorizationType
  
  

  public init () {
    
  }
  
}

public protocol AuthorizationManager<AuthorizationType> {
  associatedtype AuthorizationType
  func fetch() async throws -> AuthorizationType?
}


public protocol Service<SessionType>: ServiceProtocol {
  typealias SessionAuthenticationManager =
    AuthorizationManager<SessionType.AuthorizationType>
  associatedtype SessionType: Session where SessionType.ResponseType.DataType == API.ResponseDataType
  var authorizationManager: any SessionAuthenticationManager { get }
  var session: SessionType { get }

  var api : API { get }
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
