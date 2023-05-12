import Foundation
import PrchModel

public struct StopTunnelRequest: ServiceCall {
  public typealias SuccessType = Empty

  public typealias BodyType = Empty

  public typealias ServiceAPI = Ngrok.API

  public var parameters: [String: String] {
    [:]
  }

  public static var requiresCredentials: Bool {
    false
  }

  public init(name: String) {
    self.name = name
  }

  public let method = RequestMethod.DELETE

  public var path: String {
    "api/tunnels/\(name)"
  }

  public let queryParameters = [String: Any]()

  public let headers = [String: String]()

  public let name: String
}
