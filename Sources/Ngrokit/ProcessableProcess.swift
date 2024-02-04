//
//  ProcessableProcess.swift
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

#if os(macOS)

  ///   A process that can be processed and executed.
  ///
  ///   - Note: This class is only available on macOS.
  ///
  ///   - Important: Make sure to set the `standardErrorPipe`
  ///   property before executing the process.
  ///
  ///   - SeeAlso: `Processable`
  public final class ProcessableProcess: Process, Processable {
    /// The type of pipe used for standard error.
    public typealias PipeType = Pipe

    /// The pipe used for standard error.
    public var standardErrorPipe: Pipe? {
      get {
        standardError as? Pipe
      }
      set {
        standardError = newValue
      }
    }

    ///     Initializes a new `ProcessableProcess` instance.
    ///
    ///     - Parameters:
    ///       - executableFilePath: The file path of the executable.
    ///       - scheme: The scheme to use.
    ///       - port: The port to use.
    ///
    ///     - Important: Make sure to set the `standardErrorPipe`
    ///     property before executing the process.
    public init(executableFilePath: String, scheme: String, port: Int) {
      super.init()
      super.executableURL = .init(filePath: executableFilePath)
      super.arguments = [scheme, port.description]
    }

    ///     Sets the termination handler closure for the process.
    ///
    ///     - Parameter closure: The closure to be called when the process terminates.
    public func setTerminationHandler(
      _ closure: @escaping @Sendable (ProcessableProcess) -> Void
    ) {
      super.terminationHandler = { process in
        guard let pprocess = process as? ProcessableProcess else {
          assertionFailure()
          closure(self)
          return
        }
        closure(pprocess)
      }
    }

    ///     Creates a new pipe.
    ///
    ///     - Returns: A new `Pipe` instance.
    public func createPipe() -> Pipe {
      Pipe()
    }
  }

  extension Pipe: Pipable {}
#endif
