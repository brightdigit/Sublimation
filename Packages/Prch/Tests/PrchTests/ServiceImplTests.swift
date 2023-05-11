import Prch
import PrchModel
import XCTest

extension Dictionary where Key == String, Value == String {
  static func random(withCount count: Int) -> Self {
    Dictionary(uniqueKeysWithValues: (0 ..< count).map { _ in
      UUID()
    }.map { key in
      (key.uuidString, key.uuidString)
    })
  }
}

extension Data {
  static func random(withCount count: Int = 255) -> Self {
    Data((0 ..< count).map { _ in
      UInt8.random(in: 0 ... 255)
    })
  }
}

class MockerCoder: Decoder, Encoder {
  internal init(expectedSuccess: MockSessionSuccess) {
    self.expectedSuccess = expectedSuccess
  }

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  var passedBody: MockBody?
  let expectedSuccess: MockSessionSuccess
  func encode<CodableType>(_ value: CodableType) throws -> Data where CodableType: Encodable {
    passedBody = value as? MockBody
    return try encoder.encode(value)
  }

  func decode<CodableType>(_: CodableType.Type, from data: Data) throws -> CodableType where CodableType: Decodable {
    if let success = expectedSuccess as? CodableType {
      return success
    }
    return try decoder.decode(CodableType.self, from: data)
  }

  typealias DataType = Data
}

struct MockSessionRequest {}

struct MockSessionResponse: SessionResponse {
  let data: Data

  typealias DataType = Data

  let statusCode: Int
}

struct MockCreds: SessionAuthorization {
  var httpHeaders: [String: String] {
    [:]
  }
}

class MockSession: Session {
  func data<RequestType>(request: RequestType, withBaseURL _: URLComponents, withHeaders _: [String: String], authorizationManager _: any AuthorizationManager<AuthorizationType>, usingEncoder _: any Encoder<Data>) async throws -> MockSessionResponse where RequestType: PrchModel.ServiceCall {
    passedRequest = request
    return MockSessionResponse(data: data, statusCode: statusCode)
  }

  typealias RequestDataType = Data

  typealias AuthorizationType = SessionAuthorization

  let statusCode: Int = .random(in: 100 ... 999)
  let data: Data = .random()
  var passedRequest: (any ServiceCall)?
  func data<RequestType: ServiceCall>(request: RequestType, withBaseURL _: URLComponents, withHeaders _: [String: String], authorization _: MockCreds?, usingEncoder _: any Encoder<Data>) async throws -> MockSessionResponse {
    passedRequest = request
    return MockSessionResponse(data: data, statusCode: statusCode)
  }

  typealias ResponseType = MockSessionResponse
}

struct MockSessionSuccess: ContentDecodable, Codable, Equatable {
  let id: UUID
}

struct MockBody: ContentEncodable, Codable, Equatable {
  let id: UUID
}

struct MockAPI: API {
  let baseURLComponents: URLComponents

  let headers: [String: String]

  let encoder: any Encoder<Data>

  let decoder: any Decoder<Data>

  typealias RequestDataType = Data

  typealias ResponseDataType = Data
}

struct MockSessionGenericRequest: ServiceCall, Equatable {
  typealias ServiceAPI = MockAPI

  internal init(body: MockBody, path: String, parameters: [String: String], method: PrchModel.RequestMethod, headers: [String: String], requiresCredentials _: Bool) {
    self.body = body
    self.path = path
    self.parameters = parameters
    self.method = method
    self.headers = headers
  }

  typealias SuccessType = MockSessionSuccess

  var body: MockBody

  typealias BodyType = MockBody

  var path: String

  var parameters: [String: String]

  var method: PrchModel.RequestMethod

  var headers: [String: String]

  static var requiresCredentials: Bool {
    false
  }

  func isValidStatusCode(_: Int) -> Bool {
    // self.passedStatusCode = statusCode
    true
  }
}

struct MockAuthenticationManager: AuthorizationManager {
  let value: MockCreds?
  func fetch() async throws -> SessionAuthorization? {
    value
  }

  typealias AuthorizationType = SessionAuthorization
}

class MockService: Service {
  internal init(api: MockAPI, session: MockSession, authorizationManager: any SessionAuthenticationManager) {
    self.api = api
    self.session = session
    self.authorizationManager = authorizationManager
  }

  internal convenience init(baseURLComponents: URLComponents, headers: [String: String], creds: MockCreds?, session: MockSession, coder: MockerCoder) {
    let api = MockAPI(baseURLComponents: baseURLComponents, headers: headers, encoder: coder, decoder: coder)
    let manager = MockAuthenticationManager(value: creds)
    self.init(api: api, session: session, authorizationManager: manager)
  }

  typealias SessionType = MockSession
  typealias ServiceAPI = MockAPI

  var api: MockAPI
  var session: MockSession
  var authorizationManager: any SessionAuthenticationManager
}

final class ServiceImplTests: XCTestCase {
  func testExample() async throws {
    let successID = UUID()
    let session = MockSession()
    let coder = MockerCoder(expectedSuccess: .init(id: successID))
    let service = MockService(
      baseURLComponents: .random(),
      headers: .random(withCount: 5),
      creds: .init(),
      session: session,
      coder: coder
    )

    let request = MockSessionGenericRequest(body: .init(id: .init()), path: UUID().uuidString, parameters: .random(withCount: 5), method: RequestMethod.allCases.randomElement()!, headers: .random(withCount: 5), requiresCredentials: false)

    let response = try await service.request(request)

    let actualRequest = session.passedRequest as? MockSessionGenericRequest
    XCTAssertEqual(actualRequest, request)
    XCTAssertEqual(response.id, successID)
  }
}
