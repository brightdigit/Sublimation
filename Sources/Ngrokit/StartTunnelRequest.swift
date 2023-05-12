import Foundation
import PrchModel

public struct StartTunnelRequest: ServiceCall {
  public typealias SuccessType = NgrokTunnel

  public typealias BodyType = NgrokTunnelRequest

  public typealias ServiceAPI = Ngrok.API

  public static var requiresCredentials: Bool {
    false
  }

  public init(body: NgrokTunnelRequest) {
    self.body = body
  }

  public var method: PrchModel.RequestMethod = .POST

  public let path: String = "api/tunnels"

  public var parameters: [String: String] = [:]

  public let headers: [String: String] = [
    "Content-Type": "application/json"
  ]

  public let name: String = ""

  public let body: NgrokTunnelRequest
}
