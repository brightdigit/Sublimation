import Foundation
import PrchModel

public protocol ServiceProtocol {
  associatedtype API: BaseAPI
  func request<RequestType: ServiceCall>(
    _ request: RequestType
  ) async throws -> RequestType.SuccessType.DecodableType
    where RequestType.API == Self.API
}
