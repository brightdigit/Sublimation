import AsyncHTTPClient
import Foundation
import OpenAPIRuntime

enum NetworkResult<T> {
  case success(T)
  case connectionRefused(ClientError)
  case failure(any Error)
}

extension NetworkResult {
  init(error: any Error) {
    guard let error = error as? ClientError else {
      self = .failure(error)
      return
    }

    guard let posixError = error.underlyingError as? HTTPClient.NWPOSIXError else {
      self = .failure(error)
      return
    }

    guard posixError.errorCode == .ECONNREFUSED else {
      self = .failure(error)
      return
    }

    self = .connectionRefused(error)
  }

  init(_ closure: @escaping () async throws -> T) async {
    do {
      self = try await .success(closure())
    } catch {
      self = .init(error: error)
    }
  }

  func get() throws -> T? {
    switch self {
    case .connectionRefused:
      return nil
    case let .failure(error):
      throw error
    case let .success(item):
      return item
    }
  }
}
