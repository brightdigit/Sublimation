//
//  Result.swift
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

/**
 An extension to the `Result` type.

 This extension adds a convenience initializer that allows creating a `Result` instance with optional success and failure values.

 - Note: This extension is internal and should not be used outside of the module.

 - Warning: The `EmptyError` type is an internal error type used when both success and failure values are `nil`.

 - Parameters:
   - success: An optional success value.
   - failure: An optional failure value.

 - Throws: An `EmptyError` if both success and failure values are `nil`.

 - Returns: A `Result` instance with either a success or failure value.
 */
extension Result {
  internal struct EmptyError: Error {}

  internal init(success: Success?, failure: Failure?) where Failure == any Error {
    if let failure {
      self = .failure(failure)
    } else if let success {
      self = .success(success)
    } else {
      self = .failure(EmptyError())
    }
  }
}
