//
//  NetworkResult.swift
//  Sublimation
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

package typealias AnyTunnelNetworkResult<ConnectionErrorType: Error> =
  NetworkResult<(any Tunnel)?, ConnectionErrorType>

/// Represents the result of a network operation.
///
/// - success: The operation was successful and contains the result value.
/// - connectionRefused: The connection was refused by the server.
/// - failure: The operation failed with an error.
///
/// - Note: This type is internal and should not be used outside of the framework.
public enum NetworkResult<T, ConnectionErrorType: Error> {
  case success(T)
  case connectionRefused(ConnectionErrorType)
  case failure(any Error)
}

extension NetworkResult {
  public init(error: any Error, isConnectionRefused: @escaping (ConnectionErrorType) -> Bool) {
    guard let error = error as? ConnectionErrorType else {
      self = .failure(error)
      return
    }

    if isConnectionRefused(error) {
      self = .connectionRefused(error)
      return
    }

    self = .failure(error)
  }

  public init(
    _ closure: @escaping () async throws -> T,
    isConnectionRefused: @escaping (ConnectionErrorType) -> Bool
  ) async {
    do {
      self = try await .success(closure())
    } catch {
      self = .init(error: error, isConnectionRefused: isConnectionRefused)
    }
  }

  public func get() throws -> T? {
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
