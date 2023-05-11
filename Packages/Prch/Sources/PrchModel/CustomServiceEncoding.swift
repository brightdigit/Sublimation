@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol CustomServiceEncoding<DataType> {
  associatedtype DataType
  var encoder: any Encoder<DataType> { get }
}
