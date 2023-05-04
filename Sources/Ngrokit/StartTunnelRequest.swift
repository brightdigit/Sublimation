import Foundation
import PrchModel

public struct StartTunnelRequest: ServiceCall {
  
  public typealias SuccessType = NgrokTunnel
  
  public typealias BodyType = NgrokTunnelRequest
  
  
  
  public static var requiresCredentials: Bool {
    return false
  }
  
  public init(body: NgrokTunnelRequest) {
    self.body = body
  }


  public var method: PrchModel.RequestMethod = .POST

  public let path: String = "/api/tunnels"
  
  public var parameters: [String : String] = [:]

  public let headers: [String: String] = [
    "Content-Type": "application/json"
  ]

//  func bodyEncoder(_ encoder: Prch.RequestEncoder) throws -> Data {
//    try encoder.encode(body)
//  }
//
//  public var encodeBody: ((Prch.RequestEncoder) throws -> Data)? {
//    self.bodyEncoder(_:)
//  }

  public let name: String = ""

  public let body: NgrokTunnelRequest
}
