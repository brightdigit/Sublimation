import AsyncHTTPClient
import Foundation
import NIOCore
import NIOHTTP1
import Prch

public protocol NIOResponse : SessionResponse {
  var status: HTTPResponseStatus { get }
  var body: ByteBuffer? { get }
}

extension NIOResponse {
  public var statusCode: Int {
    Int(self.status.code)
  }
  
  public var data: Data {
    body.map {
      Data(buffer: $0)
    } ?? .init()
  }
}
