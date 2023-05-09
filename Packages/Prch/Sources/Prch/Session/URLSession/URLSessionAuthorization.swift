import Foundation

public protocol URLSessionAuthorization {
  var httpHeaders: [String: String] { get }
}
