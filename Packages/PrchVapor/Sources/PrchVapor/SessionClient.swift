import Prch
import PrchModel
import Vapor

public extension Client {
  func session() -> any Prch.Session {
    return SessionClient(client: self)
  }
}

public struct SessionClient: Prch.Session {
  public typealias RequestType = ClientRequest

  public typealias ResponseType = ClientResponse

  public typealias AuthorizationType = SessionAuthorization

  let client: Vapor.Client

  public init(client: Vapor.Client) {
    self.client = client
  }

  public func data<RequestType: ServiceCall>(
    request: RequestType,
    withBaseURL baseURLComponents: URLComponents,
    withHeaders headers: [String: String],
    authorizationManager _: any AuthorizationManager<SessionAuthorization>,
    usingEncoder encoder: any Encoder<Data>
  ) async throws -> ClientResponse {
    var componenents = baseURLComponents
    componenents.path = "/\(request.path)"
    componenents.queryItems = request.parameters.map(URLQueryItem.init)

    var urlRequest = ClientRequest()
    urlRequest.url = URI(components: componenents)
    urlRequest.method = HTTPMethod(rawValue: request.method.rawValue)

    let headerDict = request.headers.merging(
      headers, uniquingKeysWith: { requestHeaderKey, _ in
        requestHeaderKey
      }
    )
    urlRequest.headers = HTTPHeaders(Array(headerDict))

    if case let .encodable(value) = request.body.encodable {
      urlRequest.body = try ByteBuffer(data: encoder.encode(value))
    }
    return try await client.send(urlRequest)
  }
}
