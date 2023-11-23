import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Result {
  init(success: Success?, failure: Failure?) where Failure == Error {
    if let failure = failure {
      self = .failure(failure)
    } else if let success = success {
      self = .success(success)
    } else {
      self = .failure(EmptyError())
    }
  }

  struct EmptyError: Error {}
}

extension Optional {
  func flatTuple<OtherType>(_ other: OtherType?) -> (Wrapped, OtherType)? {
    flatMap { wrapped in
      other.map { (wrapped, $0) }
    }
  }
}

extension URLSession {
  public static func ephemeral() -> URLSession {
    URLSession(configuration: .ephemeral)
  }

  func dataAsync(for request: URLRequest) async throws -> (Data, URLResponse) {
    #if !canImport(FoundationNetworking)
      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        return try await self.data(for: request)
      }
    #endif

    return try await withCheckedThrowingContinuation { continuation in
      let task = self.dataTask(with: request) { data, response, error in
        continuation.resume(
          with: .init(
            success: data.flatTuple(response),
            failure: error
          )
        )
      }
      task.resume()
    }
  }

  func dataAsync(from url: URL) async throws -> (Data, URLResponse) {
    #if !canImport(FoundationNetworking)
      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        return try await data(for: .init(url: url))
      }
    #endif
    return try await dataAsync(for: .init(url: url))
  }
}

public struct URLSessionClient<Key>: KVdbTunnelClient {
  public init(session: URLSession = .ephemeral()) {
    self.session = session
  }

  let session: URLSession
  public func getValue(
    ofKey key: Key,
    fromBucket bucketName: String
  ) async throws -> URL {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)

    let data = try await session.dataAsync(from: url).0

    guard let url = String(data: data, encoding: .utf8).flatMap(URL.init(string:)) else {
      throw NgrokServerError.invalidURL
    }

    return url
  }

  public func saveValue(
    _ value: URL,
    withKey key: Key,
    inBucket bucketName: String
  ) async throws {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    var request = URLRequest(url: url)
    request.httpBody = value.absoluteString.data(using: .utf8)
    let (data, response) = try await session.dataAsync(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel(nil, nil)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel(httpResponse.statusCode, data)
    }
  }
}
