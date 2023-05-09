import Prch
import PrchNIO
import Vapor

//
//protocol NIOResponse : SessionResponse {
//  var status: HTTPStatus { get }
//  var body: ByteBuffer? { get }
//}
//
//extension NIOResponse {
//  public var statusCode: Int {
//    Int(self.statusCode)
//  }
//
//  public var data: Data {
//    body.map {
//      Data(buffer: $0)
//    } ?? .init()
//  }
//}


extension ClientResponse: NIOResponse {}
