import Foundation

public protocol SessionResponse<DataType> {
  associatedtype DataType
  var statusCode: Int { get }
  var data: DataType { get }
}
