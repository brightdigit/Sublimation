/// A delegate protocol for `NgrokServer` that handles server events and errors.
public protocol NgrokServerDelegate: AnyObject, Sendable {
  ///   Notifies the delegate that a tunnel has been updated.
  ///
  ///   - Parameters:
  ///     - server: The `NgrokServer` instance that triggered the event.
  ///     - tunnel: The updated `Tunnel` object.
  ///
  ///   - Note: This method is called whenever a tunnel's status or configuration changes.
  func server(_ server: any NgrokServer, updatedTunnel tunnel: Tunnel)

  ///   Notifies the delegate that an error has occurred.
  ///
  ///   - Parameters:
  ///     - server: The `NgrokServer` instance that triggered the event.
  ///     - error: The error that occurred.
  ///
  ///   - Note: This method is called whenever an error occurs during server operations.
  func server(_ server: any NgrokServer, errorDidOccur error: any Error)
}

import Ngrokit
