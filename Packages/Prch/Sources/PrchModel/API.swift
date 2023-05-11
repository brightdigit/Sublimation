import Foundation

public protocol API {
  associatedtype RequestDataType
  associatedtype ResponseDataType
  var baseURLComponents: URLComponents { get }
  var headers: [String: String] { get }
  var encoder: any Encoder<RequestDataType> { get }
  var decoder: any Decoder<ResponseDataType> { get }
}
