import Foundation

public struct JSONCoder: Coder {
  public typealias DataType = Data

  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  public init(encoder: JSONEncoder, decoder: JSONDecoder) {
    self.encoder = encoder
    self.decoder = decoder
  }

  public func encode<CodableType>(
    _ value: CodableType
  ) throws -> Data where CodableType: Encodable {
    try encoder.encode(value)
  }

  public func decode<CodableType>(
    _ type: CodableType.Type,
    from data: Data
  ) throws -> CodableType where CodableType: Decodable {
    try decoder.decode(type, from: data)
  }
}
