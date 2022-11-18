import Foundation
import Prch

public struct StartTunnelRequest: Request {
  public init(body: NgrokTunnelRequest) {
    self.body = body
  }

  public typealias ResponseType = StartTunnelResponse

  public let method: String = "POST"

  public let path: String = "/api/tunnels"

  public let queryParameters: [String: Any] = [:]

  public let headers: [String: String] = [
    "Content-Type": "application/json"
  ]

  func bodyEncoder(_ encoder: Prch.RequestEncoder) throws -> Data {
    try encoder.encode(body)
  }

  public var encodeBody: ((Prch.RequestEncoder) throws -> Data)? {
    self.bodyEncoder(_:)
  }

  public let name: String = ""

  public let body: NgrokTunnelRequest
}
