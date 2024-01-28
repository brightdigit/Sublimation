import PrchModel

@available(*, deprecated)
public struct NgrokTunnelRequest: Codable, Content {
  init(addr: String, proto: String, name: String) {
    self.addr = addr
    self.proto = proto
    self.name = name
  }

  public init(port: Int, proto: String = "http", name: String = "vapor-development") {
    self.init(addr: port.description, proto: proto, name: name)
  }

  let addr: String
  let proto: String
  let name: String
}
