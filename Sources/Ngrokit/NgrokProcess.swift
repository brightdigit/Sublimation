import Foundation

public actor NgrokProcess {
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

  private var terminationHandler: ((any Error) -> Void)?
  private let process: Process
  private let pipe: Pipe

  public func run(onError: @Sendable @escaping (any Error) -> Void) throws {
    terminationHandler = onError
    try process.run()
  }
}
