extension Encodable where Self: ContentEncodable {
  public var encodable: EncodableValue {
    .encodable(self)
  }
}
