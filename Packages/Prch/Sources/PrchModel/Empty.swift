public struct Empty: ContentDecodable, ContentEncodable, Equatable {
  public static func decode<CoderType>(
    _: CoderType.DataType,
    using _: CoderType
  ) throws where CoderType: Decoder {}

  public static var decodable: Void.Type {
    Void.self
  }

  public typealias DecodableType = Void

  public var encodable: EncodableValue {
    .empty
  }

  public static let value = Empty()

  private init() {}

  public init(decoded _: Void) throws {}
}
