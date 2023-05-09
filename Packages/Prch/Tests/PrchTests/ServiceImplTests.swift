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

class MockerCoder: Coder {
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

struct MockCreds {}

class MockSession: Session {
  let statusCode: Int = .random(in: 100 ... 999)
  let data: Data = .random()
  var passedRequest: (any ServiceCall)?
  func data<RequestType>(request: RequestType, withBaseURL _: URLComponents, withHeaders _: [String: String], authorization _: MockCreds?, usingEncoder _: any Coder<Data>) async throws -> MockSessionResponse where RequestType: Prch.ServiceCall {
    passedRequest = request
    return MockSessionResponse(data: data, statusCode: statusCode)
  }

  typealias RequestType = MockSessionRequest

  typealias ResponseType = MockSessionResponse
}

struct MockSessionSuccess: ContentDecodable, Codable, Equatable {
  let id: UUID
}

struct MockBody: ContentEncodable, Codable, Equatable {
  let id: UUID
}

struct MockSessionGenericRequest: ServiceCall, Equatable {
  internal init(body: MockBody, path: String, parameters: [String: String], method: String, headers: [String: String], requiresCredentials: Bool) {
    self.body = body
    self.path = path
    self.parameters = parameters
    self.method = method
    self.headers = headers
    self.requiresCredentials = requiresCredentials
  }

  typealias SuccessType = MockSessionSuccess

  var body: MockBody

  typealias BodyType = MockBody

  var path: String

  var parameters: [String: String]

  var method: String

  var headers: [String: String]

  var requiresCredentials: Bool

  func isValidStatusCode(_: Int) -> Bool {
    // self.passedStatusCode = statusCode
    true
  }
}

final class ServiceImplTests: XCTestCase {
  func testExample() async throws {
    let successID = UUID()
    let session = MockSession()
    let coder = MockerCoder(expectedSuccess: .init(id: successID))
    let service = Service(
      baseURLComponents: .random(),
      fetchAuthorization: { MockCreds() },
      session: session,
      headers: .random(withCount: 5),
      coder: coder
    )

    let request = MockSessionGenericRequest(body: .init(id: .init()), path: UUID().uuidString, parameters: .random(withCount: 5), method: UUID().uuidString, headers: .random(withCount: 5), requiresCredentials: false)

    let response = try await service.request(request)

    let actualRequest = session.passedRequest as? MockSessionGenericRequest
    XCTAssertEqual(actualRequest, request)
    XCTAssertEqual(response.id, successID)
  }
}
