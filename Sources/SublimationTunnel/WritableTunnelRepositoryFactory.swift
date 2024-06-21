//
//  WritableTunnelRepositoryFactory.swift
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

// #if os(macOS)
//  @_exported import class Ngrokit.ProcessableProcess
// #endif
// @_exported import struct Ngrokit.NgrokClient

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A factory protocol for creating writable tunnel repositories.
///
/// This protocol extends the `TunnelRepositoryFactory` protocol
/// and requires the associated `TunnelRepositoryType`
/// to conform to the `WritableTunnelRepository` protocol.
///
/// - Note: This protocol is part of the `Sublimation` framework.
///
/// - SeeAlso: `TunnelRepositoryFactory`
/// - SeeAlso: `WritableTunnelRepository`
public protocol WritableTunnelRepositoryFactory: TunnelRepositoryFactory
  where TunnelRepositoryType: WritableTunnelRepository {}
