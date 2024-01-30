//
//  URLSession.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLSession {
  public static func ephemeral() -> URLSession {
    URLSession(configuration: .ephemeral)
  }

  internal func dataAsync(for request: URLRequest) async throws -> (Data, URLResponse) {
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

  internal func dataAsync(from url: URL) async throws -> (Data, URLResponse) {
    #if !canImport(FoundationNetworking)
      if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
        return try await data(for: .init(url: url))
      }
    #endif
    return try await dataAsync(for: .init(url: url))
  }
}
