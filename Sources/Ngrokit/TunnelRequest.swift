import NgrokOpenAPIClient

public struct TunnelRequest: Sendable {
  init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }

  public init(port: Int, proto: String = "http", name: String) {
    self.init(addr: port.description, proto: proto, name: name)
  }

  public let addr: String
  public let proto: String
  public let name: String
}

extension Components.Schemas.TunnelRequest {
  init(request: TunnelRequest) {
    self.init(addr: request.addr, proto: request.proto, name: request.name)
  }
}
