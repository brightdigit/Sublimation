import Foundation


public protocol BaseAPI {
  associatedtype RequestDataType
  associatedtype ResponseDataType
  static var baseURLComponents: URLComponents { get }
  static var headers: [String: String] { get }
  static var encoder: any Encoder<RequestDataType> { get }
  static var decoder: any Decoder<ResponseDataType> { get }
}


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

extension ServiceCall {
  public func resolveEncoder<DataType>()  -> any Encoder<DataType> where API : BaseAPI, API.RequestDataType == DataType {
    if #available(macOS 13.0.0, iOS 16.0, *) {
        if let custom = self as? any CustomServiceEncoding<DataType> {
          return custom.encoder
        } else {
          return  API.encoder
        }
      } else {
        return  API.encoder
      }
  }
}

extension ServiceCall {
  public func resolveDecoder<DataType>()  -> any Decoder<DataType> where API : BaseAPI, API.ResponseDataType == DataType {
    if #available(macOS 13.0.0, iOS 16.0, *) {
        if let custom = self as? any CustomServiceDecoding<DataType> {
          return custom.decoder
        } else {
          return  API.decoder
        }
      } else {
        return  API.decoder
      }
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
