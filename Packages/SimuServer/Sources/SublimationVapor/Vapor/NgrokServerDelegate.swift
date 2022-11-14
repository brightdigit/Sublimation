import Ngrokit

public protocol NgrokServerDelegate {
  func server(_ server: NgrokServer, updatedTunnel tunnel: NgrokTunnel)
  func server(_ server: NgrokServer, errorDidOccur error: Error)
  func server(_ server: NgrokServer, failedWithError error: Error)
}
