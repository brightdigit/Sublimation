import Foundation
import Prch

public struct StopTunnelResponse: Response {
  public let response: Prch.ClientResult<Void, FailureType>

  public typealias SuccessType = Void

  public typealias FailureType = Ngrok.API.Error

  public typealias APIType = Ngrok.API

  public var statusCode: Int

  public init(statusCode: Int, data _: Data, decoder _: Prch.ResponseDecoder) throws {
    self.statusCode = statusCode
    response = statusCode == 204 ? .success(()) : .defaultResponse(statusCode, .tunnelNotFound)
  }

  public var debugDescription: String {
    response.debugDescription
  }

  public var description: String {
    response.description
  }
}
