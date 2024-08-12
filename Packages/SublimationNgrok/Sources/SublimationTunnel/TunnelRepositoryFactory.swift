//
//  TunnelRepositoryFactory.swift
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

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A factory for creating tunnel repositories.
///
/// The factory is responsible for
/// setting up the client and returning a tunnel repository.
///
/// - Note: The factory must be `Sendable`.
///
/// - Note: The associated type `TunnelRepositoryType` must conform to `TunnelRepository`.
///
/// - Note: The factory must implement the `setupClient` method,
/// which takes a `TunnelClientType` and returns a `TunnelRepositoryType`.
///
/// - Warning: The factory may require the `FoundationNetworking` module to be imported.
///
/// - SeeAlso: `TunnelRepository`
/// - SeeAlso: `KVdbTunnelClient`
public protocol TunnelRepositoryFactory: Sendable {
  /// The type of tunnel repository created by the factory.
  associatedtype TunnelRepositoryType: TunnelRepository

  ///   Sets up the client and returns a tunnel repository.
  ///
  ///   - Parameter client: The tunnel client to use.
  ///
  ///   - Returns: A tunnel repository.
  ///
  ///   - Throws: An error if the setup fails.
  ///
  ///   - Note: The `TunnelClientType` must have a `Key` type
  ///   that matches the `Key` type of the `TunnelRepositoryType`.
  func setupClient<TunnelClientType: TunnelClient>(_ client: TunnelClientType)
    -> TunnelRepositoryType where TunnelClientType.Key == TunnelRepositoryType.Key
}
