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

  #if canImport(FoundationNetworking)
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
      try await withCheckedThrowingContinuation { continuation in
        self.dataTask(with: request)
        let task = self.dataTask(with: request) { data, response, error in
          continuation.resume(with: .init(success: data.flatTuple(response), failure: error))
        }
        task.resume()
      }
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
      try await data(for: .init(url: url))
    }
  #endif
}

public struct URLSessionClient<Key>: KVdbTunnelClient {
  internal init(session: URLSession = .ephemeral()) {
    self.session = session
  }

  let session: URLSession
  public func getValue(ofKey key: Key, fromBucket bucketName: String) async throws -> URL {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)

    let data = try await session.data(from: url).0

    guard let url = String(data: data, encoding: .utf8).flatMap(URL.init(string:)) else {
      throw NgrokServerError.invalidURL
    }

    return url
  }

  public func saveValue(_ value: URL, withKey key: Key, inBucket bucketName: String) async throws {
    let url = KVdb.construct(URL.self, forKey: key, atBucket: bucketName)
    var request = URLRequest(url: url)
    request.httpBody = value.absoluteString.data(using: .utf8)
    let (data, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NgrokServerError.cantSaveTunnel(nil, nil)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw NgrokServerError.cantSaveTunnel(httpResponse.statusCode, data)
    }
  }
}
