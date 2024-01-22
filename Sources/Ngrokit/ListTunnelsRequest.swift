import Foundation
import PrchModel

@available(*, deprecated)
public struct ListTunnelsRequest: ServiceCall {
  public typealias ServiceAPI = Ngrok.PrchAPI

  public let parameters: [String: String] = [:]

  public static var requiresCredentials: Bool {
    true
  }

  public typealias SuccessType = NgrokTunnelResponse

  public typealias BodyType = Empty

  public init() {}

  public var method: PrchModel.RequestMethod = .GET

  public let path = "api/tunnels"

  public let queryParameters = [String: Any]()

  public let headers = [String: String]()
}
