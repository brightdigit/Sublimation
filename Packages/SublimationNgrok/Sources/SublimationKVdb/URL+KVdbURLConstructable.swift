//
//  URL+KVdbURLConstructable.swift
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

public import Foundation

#if canImport(FoundationNetworking)
  public import FoundationNetworking
#endif

/// A type representing a URL.
///
/// - Note: This type is an extension of `URL` and conforms to `KVdbURLConstructable`.
///
/// - SeeAlso: `KVdbURLConstructable`
extension URL: KVdbURLConstructable {
  ///   Initializes a `URL` instance with the given KVDB base and key bucket path.
  ///
  ///   - Parameters:
  ///     - kvDBBase: The base URL of the KVDB.
  ///     - keyBucketPath: The path to the key bucket.
  ///
  ///   - Note: This initializer is only available if `FoundationNetworking` is imported.
  ///
  ///   - Precondition: `kvDBBase` must be a valid URL.
  ///
  ///   - Postcondition: The resulting `URL` instance is constructed
  ///   by appending `keyBucketPath` to `kvDBBase`.
  public init(kvDBBase: String, keyBucketPath: String) {
    // swiftlint:disable:next force_unwrapping
    self = URL(string: kvDBBase)!.appendingPathComponent(keyBucketPath)
  }
}
