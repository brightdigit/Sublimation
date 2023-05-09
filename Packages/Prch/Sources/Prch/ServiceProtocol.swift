import Foundation
import PrchModel

public protocol ServiceProtocol {
  func request<RequestType: ServiceCall>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
}
