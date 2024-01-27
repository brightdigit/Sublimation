import Foundation

public protocol TunnelRepository: Sendable {
  associatedtype Key: Sendable
  func tunnel(forKey key: Key) async throws -> URL?
}
