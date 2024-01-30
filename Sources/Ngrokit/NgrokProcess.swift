//
//  NgrokProcess.swift
//  Sublimation
//
//  Created by NgrokProcess.swift
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

public actor NgrokProcess {
  private var terminationHandler: ((any Error) -> Void)?
  private let process: Process
  private let pipe: Pipe

  public init(
    ngrokPath: String,
    httpPort: Int
  ) {
    let process = Process()
    process.executableURL = .init(filePath: ngrokPath)
    process.arguments = ["http", httpPort.description]
    self.init(process: process)
  }

  private init(
    terminationHandler: (@Sendable (any Error) -> Void)? = nil,
    process: Process, pipe: Pipe? = nil
  ) {
    self.terminationHandler = terminationHandler
    self.process = process
    if let pipe {
      self.pipe = pipe
    } else {
      let pipe = Pipe()
      self.process.standardError = pipe
      self.pipe = pipe
    }
  }

  public func run(onError: @Sendable @escaping (any Error) -> Void) throws {
    terminationHandler = onError
    try process.run()
  }
}
