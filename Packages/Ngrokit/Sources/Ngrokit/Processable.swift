//
//  Processable.swift
//  Ngrokit
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

/// A protocol for objects that can be processed.
///
/// - Note: This protocol is `Sendable` and `AnyObject`.
///
/// - Important: The associated type `PipeType` must conform to `Pipable`.
///
/// - SeeAlso: `Pipable`
///
/// - SeeAlso: `TerminationReason`
///
/// - SeeAlso: `PipeType`
///
/// - SeeAlso: `run()`
///
/// - SeeAlso: `setTerminationHandler(_:)`
///
/// - SeeAlso: `createPipe()`
///
/// - SeeAlso: `standardErrorPipe`
///
/// - SeeAlso: `terminationReason`
///
/// - Requires: `executableFilePath`, `scheme`, and `port` parameters to initialize.
///
/// - Requires: `run()` method to be implemented.
///
/// - Requires: `standardErrorPipe` property to be gettable and settable.
///
/// - Requires: `terminationReason` property to be gettable.
///
/// - Requires: `setTerminationHandler(_:)` method to be implemented.
///
public protocol Processable: Sendable, AnyObject {
  /// The associated type for the pipe used by the process.
  associatedtype PipeType: Pipable

  /// The pipe used for standard error output.
  var standardError: PipeType? { get set }

  /// The reason for the process termination.
  var terminationReason: TerminationReason { get }

  ///   Initializes a `Processable` object.
  ///
  ///   - Parameters:
  ///     - executableFilePath: The file path of the executable.
  ///     - scheme: The scheme to use.
  ///     - port: The port to use.
  ///
  ///   - Requires: This initializer must be implemented.
  init(executableFilePath: String, scheme: String, port: Int)

  /// Sets a closure to be called when the process terminates.
  ///
  /// - Requires: This method must be implemented.
  ///
  /// - Parameter closure: The closure to be called.

  func setTerminationHandler(_ closure: @escaping @Sendable (Self) -> Void)

  ///   Creates a new pipe.
  ///
  ///   - Returns: A new instance of `PipeType`.
  ///
  ///   - Requires: This method must be implemented.
  func createPipe() -> PipeType

  ///   Runs the process.
  ///
  ///   - Throws: An error if the process fails.
  ///
  ///   - Requires: This method must be implemented.
  func run() throws
  func terminate()
}
