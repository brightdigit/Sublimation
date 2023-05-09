public protocol Coder<DataType> {
  associatedtype DataType

  func encode<CodableType: Encodable>(_ value: CodableType) throws -> DataType

  func decode<CodableType: Decodable>(
    _: CodableType.Type,
    from data: DataType
  )
    throws -> CodableType
}

extension Coder {
  public func decodeContent<CodableType: ContentDecodable>(
    _: CodableType.Type,
    from data: DataType
  )
    throws -> CodableType.DecodableType {
    try CodableType.decode(data, using: self)
  }
}
