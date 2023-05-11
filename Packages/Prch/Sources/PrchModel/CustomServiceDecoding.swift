@available(macOS 13, iOS 16, watchOS 9, tvOS 16, *)
public protocol CustomServiceDecoding<DataType> {
  associatedtype DataType
  var decoder: any Decoder<DataType> { get }
}
