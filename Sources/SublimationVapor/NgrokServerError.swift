import Sublimation
import Vapor

extension NgrokServerError {
  static func cantSaveTunnel(_ response: ClientResponse) -> NgrokServerError {
    let code = Int(response.status.code)
    let data = response.body.map { Data(buffer: $0, byteTransferStrategy: .automatic) }
    return .cantSaveTunnel(code, data)
  }
}
