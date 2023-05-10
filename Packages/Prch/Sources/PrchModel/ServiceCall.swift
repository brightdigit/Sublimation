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

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol CustomServiceEncoding<DataType> {
  associatedtype DataType
  var encoder: any Encoder<DataType> { get }
}

@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol CustomServiceDecoding<DataType> {
  associatedtype DataType
  var decoder: any Decoder<DataType> { get }
}
