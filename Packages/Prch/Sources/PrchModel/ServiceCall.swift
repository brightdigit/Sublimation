import Foundation

public protocol ServiceCall {
  associatedtype SuccessType: ContentDecodable
  associatedtype BodyType: ContentEncodable
  associatedtype API
  var path: String { get }
  var parameters: [String: String] { get }
  var method: RequestMethod { get }
  var headers: [String: String] { get }
  var body: BodyType { get }
  static var requiresCredentials: Bool { get }
  func isValidStatusCode(_ statusCode: Int) -> Bool
}

extension ServiceCall {
  public func isValidStatusCode(_ statusCode: Int) -> Bool {
    statusCode / 100 == 2
  }
}

extension ServiceCall where BodyType == Empty {
  public var body: BodyType {
    .value
  }
}
