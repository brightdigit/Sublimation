import AsyncHTTPClient
import Foundation
import NIOHTTP1
import Prch
import PrchModel

extension HTTPClient : Session {
  public func data<RequestType>(request: RequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String : String], authorizationManager: any AuthorizationManager<AuthorizationType>, usingEncoder encoder: any Coder<Data>) async throws -> Response where RequestType : PrchModel.ServiceCall {
    var componenents = baseURLComponents
    componenents.queryItems = request.parameters.map(URLQueryItem.init)

    guard let url = componenents.url?.appendingPathComponent(request.path) else {
      preconditionFailure()
    }
    
    let method = HTTPMethod(rawValue: request.method.rawValue)
    
        let headerDict = request.headers.merging(
          headers, uniquingKeysWith: { requestHeaderKey, _ in
            requestHeaderKey
          }
        )
    
        let headers = HTTPHeaders(Array(headerDict))
    
    let body : Body?
    if case let .encodable(value) = request.body.encodable {
      body = try Body.data(encoder.encode(value))
    } else {
      body = nil
    }
    
    let request = try HTTPClient.Request(url: url, method: method, headers: headers, body: body)
    
    return try await self.execute(request: request).get()
  }
  
  public typealias RequestType = Request
  
  public typealias ResponseType = Response
  
  public typealias AuthorizationType = URLSessionAuthorization
  
  
}
