import Foundation
public enum NgrokServerError: Error {
  case clientNotSetup
  case noTunnelFound
  case invalidURL
  case cantSaveTunnel(Int?, Data?)
}
