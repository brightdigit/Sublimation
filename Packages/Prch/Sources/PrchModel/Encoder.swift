public protocol Encoder<DataType> {
  associatedtype DataType

  func encode<CodableType: Encodable>(
    _ value: CodableType
  ) throws -> DataType
}
