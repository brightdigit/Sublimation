import Foundation

public protocol SessionAuthorization {
  var httpHeaders: [String: String] { get }
}
