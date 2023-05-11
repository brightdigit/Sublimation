import Foundation
import PrchModel

public protocol ServiceProtocol {
  associatedtype ServiceAPI: API
  func request<RequestType: ServiceCall>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
    where RequestType.ServiceAPI == Self.ServiceAPI
}
