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

import AsyncHTTPClient
import Foundation
import OpenAPIRuntime
/**
 Represents the result of a network operation.

 - success: The operation was successful and contains the result value.
 - connectionRefused: The connection was refused by the server.
 - failure: The operation failed with an error.

 - Note: This type is internal and should not be used outside of the framework.
 */
internal enum NetworkResult<T> {
  case success(T)
  case connectionRefused(ClientError)
  case failure(any Error)
}

extension NetworkResult {
  /**
   Initializes a `NetworkResult` with an error.

   - Parameter error: The error that occurred.

   - Note: This initializer is internal and should not be used outside of the framework.
   */
  internal init(error: any Error) {
    guard let error = error as? ClientError else {
      self = .failure(error)
      return
    }

    #if canImport(Network)
      if let posixError = error.underlyingError as? HTTPClient.NWPOSIXError {
        guard posixError.errorCode == .ECONNREFUSED else {
          self = .failure(error)
          return
        }
        self = .connectionRefused(error)
        return
      }
    #endif

    if let clientError = error.underlyingError as? HTTPClientError {
      guard clientError == .connectTimeout else {
        self = .failure(error)
        return
      }
      self = .connectionRefused(error)
      return
    }

    self = .failure(error)
  }

  /**
   Initializes a `NetworkResult` with a closure that performs an asynchronous operation.

   - Parameter closure: The closure that performs the asynchronous operation.

   - Note: This initializer is internal and should not be used outside of the framework.
   */
  internal init(_ closure: @escaping () async throws -> T) async {
    do {
      self = try await .success(closure())
    } catch {
      self = .init(error: error)
    }
  }

  /**
   Retrieves the result value.

   - Returns: The result value if the operation was successful, `nil` if the connection was refused, or throws an error if the operation failed.

   - Throws: An error if the operation failed.

   - Note: This method is internal and should not be used outside of the framework.
   */
  internal func get() throws -> T? {
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
