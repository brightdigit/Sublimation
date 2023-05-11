import Foundation
import PrchModel

public struct ListTunnelsRequest: ServiceCall {
  
  public typealias ServiceAPI = Ngrok.API
  
  
  
  
  public let parameters: [String : String] = [:]
  
  
  
  public static var requiresCredentials: Bool {
    return true
  }
  
  
  public typealias SuccessType = NgrokTunnelResponse
  
  public typealias BodyType = Empty
  
  public init() {}

  //public let method: String = "GET"
  public var method: PrchModel.RequestMethod = .GET

  public let path = "api/tunnels"

  public let queryParameters = [String: Any]()

  public let headers = [String: String]()

//  public let encodeBody: ((Prch.RequestEncoder) throws -> Data)? = nil

  //public let name: String = ""
}
