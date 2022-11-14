import Foundation

public protocol TunnelRepository {
  associatedtype Key
  func tunnel(forKey key: Key) async throws -> URL?
}
