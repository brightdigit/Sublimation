import AsyncHTTPClient
import Foundation
import NIOCore
import NIOHTTP1
import Prch

public protocol NIOResponse: SessionResponse {
  var status: HTTPResponseStatus { get }
  var body: ByteBuffer? { get }
}

public extension NIOResponse {
  var statusCode: Int {
    Int(status.code)
  }

  var data: Data {
    body.map {
      Data(buffer: $0)
    } ?? .init()
  }
}
