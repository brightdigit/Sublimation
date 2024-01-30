import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol WritableTunnelRepository: TunnelRepository {
  func saveURL(_ url: URL, withKey key: Key) async throws
}
