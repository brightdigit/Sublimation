import Foundation
import NgrokOpenAPIClient
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum Ngrok {
  // swiftlint:disable:next force_try
  static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
}
