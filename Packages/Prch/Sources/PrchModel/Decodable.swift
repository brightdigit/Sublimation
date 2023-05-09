extension Decodable
  where Self: ContentDecodable, DecodableType == Self {
  public static var decodable: Self.Type {
    Self.self
  }

  public init(decoded: DecodableType) throws {
    self = decoded
  }

  public static func decode<CoderType>(
    _ data: CoderType.DataType,
    using coder: CoderType
  ) throws -> Self where CoderType: Coder {
    try coder.decode(Self.self, from: data)
  }
}
