//
//  NgrokProcess.swift
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

/// A protocol representing a process for running Ngrok.
///
/// - Note: This protocol is `Sendable`, allowing it to be used in asynchronous contexts.
///
/// - Important: Implementations of this protocol
/// must provide a `run` method that runs the Ngrok process.
///
/// - Parameter onError: A closure to handle any errors that occur during the process.
///
/// - Throws: An error if the process fails to run.
///
/// - SeeAlso: `NgrokProcessImplementation`
public protocol NgrokProcess: Sendable {
  ///   Runs the Ngrok process.
  ///
  ///   - Parameter onError: A closure to handle any errors that occur during the process.
  @available(*, deprecated)
  func obsoleteRun(onError: @Sendable @escaping (any Error) -> Void) async throws
  
  func run() async throws
}
