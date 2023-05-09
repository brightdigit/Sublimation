public protocol Decoder<DataType> {
  associatedtype DataType

  func decode<CodableType: Decodable>(
    _: CodableType.Type,
    from data: DataType
  )
    throws -> CodableType
}

public protocol Encoder<DataType> {
  associatedtype DataType

  func encode<CodableType: Encodable>(_ value: CodableType) throws -> DataType
}

extension Decoder {
  public func decodeContent<CodableType: ContentDecodable>(
    _: CodableType.Type,
    from data: DataType
  )
    throws -> CodableType.DecodableType {
    try CodableType.decode(data, using: self)
  }
}
