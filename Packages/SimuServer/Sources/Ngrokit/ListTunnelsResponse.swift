import Prch
import Foundation

public struct ListTunnelsResponse : Response {
  public let response: Prch.ClientResult<NgrokTunnelResponse, Never>
  
  public typealias SuccessType = NgrokTunnelResponse
  
  public typealias FailureType = Never
  
  public typealias APIType = Ngrok.API
  
  public var statusCode: Int
  
  public init(statusCode: Int, data: Data, decoder: Prch.ResponseDecoder) throws {
    self.statusCode = statusCode
    self.response = try .success(decoder.decode(SuccessType.self, from: data))
  }
  
  public var debugDescription: String {
    return self.response.debugDescription
  }
  
  public var description: String {
    return self.response.description
  }
  
}