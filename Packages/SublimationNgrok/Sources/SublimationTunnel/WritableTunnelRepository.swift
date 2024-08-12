//
//  WritableTunnelRepository.swift
//  SublimationNgrok
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

/// A repository for managing writable tunnels.
///
/// This protocol extends the `TunnelRepository` protocol
/// and adds the ability to save a URL with a key.
///
/// - Note: The `Key` type parameter
/// represents the type of key used to identify the tunnels.
///
/// - SeeAlso: `TunnelRepository`
public protocol WritableTunnelRepository<Key>: TunnelRepository {
  ///   Saves a URL with a key.
  ///
  ///   - Parameters:
  ///     - url: The URL to save.
  ///     - key: The key to associate with the URL.
  ///
  ///   - Throws: An error if the save operation fails.
  ///
  ///   - Note: This method is asynchronous.
  func saveURL(_ url: URL, withKey key: Key) async throws
}
