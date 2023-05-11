import Foundation

public protocol ServiceCall {
  associatedtype SuccessType: ContentDecodable
  associatedtype BodyType: ContentEncodable
  associatedtype ServiceAPI
  var path: String { get }
  var parameters: [String: String] { get }
  var method: RequestMethod { get }
  var headers: [String: String] { get }
  var body: BodyType { get }
  static var requiresCredentials: Bool { get }
  func isValidStatusCode(_ statusCode: Int) -> Bool
}

extension ServiceCall {
  public func isValidStatusCode(
    _ statusCode: Int
  ) -> Bool {
    statusCode / 100 == 2
  }
}

extension ServiceCall {
  public func resolveEncoder<DataType>(
    with api: ServiceAPI
  ) -> any Encoder<DataType>
    where ServiceAPI: API, ServiceAPI.RequestDataType == DataType {
    if #available(macOS 13.0.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
      if let custom = self as? any CustomServiceEncoding<DataType> {
        return custom.encoder
      } else {
        return api.encoder
      }
    } else {
      return api.encoder
    }
  }
}

extension ServiceCall {
  public func resolveDecoder<DataType>(
    with api: ServiceAPI
  ) -> any Decoder<DataType>
    where ServiceAPI: API, ServiceAPI.ResponseDataType == DataType {
    if #available(macOS 13.0.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
      if let custom = self as? any CustomServiceDecoding<DataType> {
        return custom.decoder
      } else {
        return api.decoder
      }
    } else {
      return api.decoder
    }
  }
}

extension ServiceCall where BodyType == Empty {
  public var body: BodyType {
    .value
  }
}
