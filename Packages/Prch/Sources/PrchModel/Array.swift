extension Array: ContentDecodable
  where Element: ContentDecodable & Decodable, Element.DecodableType == Element {
  public static func decode<DecoderType, DataType>(
    _ data: DataType,
    using coder: DecoderType
  ) throws -> [Element.DecodableType] where DecoderType: Decoder<DataType> {
    try coder.decode([Element.DecodableType].self, from: data)
  }

  public static var decodable: [Element.DecodableType].Type {
    Self.self
  }

  public init(decoded: [Element.DecodableType]) throws {
    self = decoded
  }

  public typealias DecodableType = [Element.DecodableType]
}
