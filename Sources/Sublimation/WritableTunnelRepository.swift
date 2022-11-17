import Foundation

public protocol WritableTunnelRepository: TunnelRepository {
  func setupClient<TunnelClientType: KVdbTunnelClient>(_ client: TunnelClientType) where TunnelClientType.Key == Self.Key
  func saveURL(_ url: URL, withKey key: Key) async throws
}
