extension Array: ContentDecodable
  where Element: ContentDecodable & Decodable, Element.DecodableType == Element {
  public static func decode<CoderType>(
    _ data: CoderType.DataType,
    using coder: CoderType
  ) throws -> [Element.DecodableType] where CoderType: Coder {
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
