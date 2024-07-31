////
////  NetworkResultTests.swift
////  Sublimation
////
////  Created by Leo Dion.
////  Copyright © 2024 BrightDigit.
////
////  Permission is hereby granted, free of charge, to any person
////  obtaining a copy of this software and associated documentation
////  files (the “Software”), to deal in the Software without
////  restriction, including without limitation the rights to use,
////  copy, modify, merge, publish, distribute, sublicense, and/or
////  sell copies of the Software, and to permit persons to whom the
////  Software is furnished to do so, subject to the following
////  conditions:
////
////  The above copyright notice and this permission notice shall be
////  included in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
////  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
////  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
////  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
////  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
////  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
////  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
////  OTHER DEALINGS IN THE SOFTWARE.
////

import AsyncHTTPClient
import OpenAPIRuntime
@testable import SublimationTunnel
@testable import SublimationVapor
import XCTest

internal func XCTAsyncAssert(
  _ expression: @escaping () async throws -> Bool,
  _ message: @autoclosure () -> String = "",
  file: StaticString = #filePath,
  line: UInt = #line
) async rethrows {
  let expressionResult = try await expression()
  XCTAssert(expressionResult, message(), file: file, line: line)
}

internal class NetworkResultTests: XCTestCase {
  // swiftlint:disable:next function_body_length
  internal func testError() {
    #if canImport(Network)
      let posixError = HTTPClient.NWPOSIXError(.ECONNREFUSED, reason: "")
      let clientPosixError = ClientError(
        operationID: "",
        operationInput: (),
        causeDescription: "",
        underlyingError: posixError
      )
      let actualPosixError: HTTPClient.NWPOSIXError? =
        NetworkResult<Void, ClientError>(error: clientPosixError, isConnectionRefused: { $0.isConnectionRefused }).underlyingClientError()
      XCTAssertEqual(
        actualPosixError?.errorCode,
        posixError.errorCode
      )
    #endif
    let timeoutError = HTTPClientError.connectTimeout

    let clientTimeoutError = ClientError(
      operationID: "",
      operationInput: (),
      causeDescription: "",
      underlyingError: timeoutError
    )

    let actualTimeoutError: HTTPClientError? =
      NetworkResult<Void, ClientError>(error: clientTimeoutError, isConnectionRefused: { $0.isConnectionRefused }).underlyingClientError()
    XCTAssertEqual(
      actualTimeoutError,
      timeoutError
    )

    #if canImport(Network)
      XCTAssert(NetworkResult<Void, ClientError>(error: posixError, isConnectionRefused: { $0.isConnectionRefused }).isFailure)
    #endif
    XCTAssert(NetworkResult<Void, ClientError>(error: timeoutError, isConnectionRefused: { $0.isConnectionRefused }).isFailure)
  }

  // swiftlint:disable:next function_body_length
  internal func testClosure() async {
    #if canImport(Network)
      let posixError = HTTPClient.NWPOSIXError(.ECONNREFUSED, reason: "")
      let clientPosixError = ClientError(
        operationID: "",
        operationInput: (),
        causeDescription: "",
        underlyingError: posixError
      )
    #endif
    let timeoutError = HTTPClientError.connectTimeout

    let clientTimeoutError = ClientError(
      operationID: "",
      operationInput: (),
      causeDescription: "",
      underlyingError: timeoutError
    )

    #if canImport(Network)
      let actualPosixError: HTTPClient.NWPOSIXError? =
        await NetworkResult<Void, ClientError> { throw clientPosixError } isConnectionRefused: { $0.isConnectionRefused }.underlyingClientError()
      XCTAssertEqual(
        actualPosixError?.errorCode,
        posixError.errorCode
      )
    #endif

    let actualTimeoutError: HTTPClientError? =
      await NetworkResult<Void, ClientError> { throw clientTimeoutError } isConnectionRefused: { $0.isConnectionRefused }.underlyingClientError()
    XCTAssertEqual(
      actualTimeoutError,
      timeoutError
    )

    #if canImport(Network)

      await XCTAsyncAssert { await NetworkResult<Void, ClientError> { throw posixError } isConnectionRefused: { $0.isConnectionRefused }.isFailure }
    #endif
    await XCTAsyncAssert { await NetworkResult<Void, ClientError> { throw timeoutError } isConnectionRefused: { $0.isConnectionRefused }.isFailure }
    await XCTAsyncAssert { await NetworkResult<Void, ClientError> { throw timeoutError } isConnectionRefused: { $0.isConnectionRefused }.isFailure }

    await XCTAsyncAssert { await NetworkResult<Void, ClientError> {} isConnectionRefused: { $0.isConnectionRefused }.isSuccess }
  }

  // swiftlint:disable:next function_body_length
  internal func testGet() async {
    #if canImport(Network)
      let posixError = HTTPClient.NWPOSIXError(.ECONNREFUSED, reason: "")
    #endif
    let timeoutError = HTTPClientError.connectTimeout

    #if canImport(Network)
      let clientPosixError = ClientError(
        operationID: "",
        operationInput: (),
        causeDescription: "",
        underlyingError: posixError
      )
    #endif
    let clientTimeoutError = ClientError(
      operationID: "",
      operationInput: (),
      causeDescription: "",
      underlyingError: timeoutError
    )
    let clientOtherError = ClientError(
      operationID: "",
      operationInput: (),
      causeDescription: "",
      underlyingError: URLError(.unknown)
    )

    #if canImport(Network)
      do {
        let value: Void? = try await NetworkResult<Void, ClientError> { throw clientPosixError } isConnectionRefused: { $0.isConnectionRefused }.get()
        XCTAssertNil(value)
      } catch {
        XCTAssertNil(error)
      }
    #endif

    do {
      let value: Void? = try await NetworkResult<Void, ClientError> { throw clientTimeoutError } isConnectionRefused: { $0.isConnectionRefused }.get()
      XCTAssertNil(value)
    } catch {
      XCTAssertNil(error)
    }

    var error: (any Error)?
    do {
      _ = try await NetworkResult<Void, ClientError> { throw clientOtherError } isConnectionRefused: { $0.isConnectionRefused }.get()
      error = nil
    } catch let caughtError as ClientError {
      error = caughtError
    } catch {
      XCTAssertNil(error)
    }
    XCTAssertNotNil(error)

    do {
      let value: ()? = try await NetworkResult<Void, ClientError> {} isConnectionRefused: { $0.isConnectionRefused }.get()
      XCTAssertNotNil(value)
    } catch {
      XCTAssertNil(error)
    }
  }
}

extension NetworkResult {
  internal var isSuccess: Bool {
    guard case .success = self else {
      return false
    }
    return true
  }

  internal var isFailure: Bool {
    guard case .failure = self else {
      return false
    }
    return true
  }

  internal func underlyingClientError<Failure: Error>() -> Failure? where ConnectionErrorType == ClientError {
    guard case let .connectionRefused(clientError) = self else {
      return nil
    }
    return clientError.underlyingError as? Failure
  }
}
