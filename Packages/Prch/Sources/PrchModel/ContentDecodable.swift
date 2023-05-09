public protocol ContentDecodable {
  associatedtype DecodableType
  static var decodable: DecodableType.Type { get }
  init(decoded: DecodableType) throws
  static func decode<CoderType: Coder>(
    _ data: CoderType.DataType,
    using coder: CoderType
  ) throws -> DecodableType
}
