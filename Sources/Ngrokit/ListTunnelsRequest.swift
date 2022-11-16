import Prch
import Foundation

public struct ListTunnelsRequest : Request {
  
  public init () {}
  
  public typealias ResponseType = ListTunnelsResponse
  
  public let method: String = "GET"
  
  public let path = "api/tunnels"
  
  public let queryParameters = [String : Any]()
  
  public let  headers = [String : String] ()
  
  public let encodeBody: ((Prch.RequestEncoder) throws -> Data)? = nil
  
  public let name: String = ""
  
  
}
