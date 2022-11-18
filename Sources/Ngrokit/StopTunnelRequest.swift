import Foundation
import Prch

public struct StopTunnelRequest: Request {
  public init(name: String) {
    self.name = name
  }

  public typealias ResponseType = StopTunnelResponse

  public let method: String = "DELETE"

  public var path: String {
    "api/tunnels/\(name)"
  }

  public let queryParameters = [String: Any]()

  public let headers = [String: String]()

  public var encodeBody: ((Prch.RequestEncoder) throws -> Data)? {
    nil
  }

  public let name: String
}
