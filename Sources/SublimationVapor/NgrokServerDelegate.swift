import Ngrokit

public protocol NgrokServerDelegate: AnyObject, Sendable {
  func server(_ server: any NgrokServer, updatedTunnel tunnel: Tunnel)
  func server(_ server: any NgrokServer, errorDidOccur error: any Error)
  func server(_ server: any NgrokServer, failedWithError error: any Error)
}
