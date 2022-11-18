import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct NgrokUrlParser {
  public static let defaultApiURL = URL(string: "http://localhost:4040/api/tunnels")!

  public func url(fromResponse response: NgrokTunnelResponse) -> URL? {
    response.tunnels.sorted { lhs, _ -> Bool in
      lhs.public_url.scheme?.hasSuffix("s") == true
    }.first?.public_url
  }

  public init() {}
}
