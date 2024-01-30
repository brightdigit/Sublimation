import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol WritableTunnelRepositoryFactory: TunnelRepositoryFactory
  where TunnelRepositoryType: WritableTunnelRepository {}
