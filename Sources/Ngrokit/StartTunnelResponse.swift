import Foundation
import Prch

public struct StartTunnelResponse: Response {
  public let response: ClientResult<NgrokTunnel, Never>

  public typealias SuccessType = NgrokTunnel

  public typealias FailureType = Never

  public typealias APIType = Ngrok.API

  public var statusCode: Int

  public init(statusCode: Int, data: Data, decoder: Prch.ResponseDecoder) throws {
    self.statusCode = statusCode
    response = try .success(decoder.decode(SuccessType.self, from: data))
  }

  public var debugDescription: String {
    response.debugDescription
  }

  public var description: String {
    response.description
  }
}
