import Foundation

public actor NgrokProcess  {
  internal init(terminationHandler: (@Sendable (any Error) -> Void)? = nil, process: Process, pipe: Pipe? = nil) {
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
  
  var terminationHandler : ((any Error) -> Void)?
  let process : Process
  let pipe : Pipe
  
  public func run (onError: @Sendable @escaping (any Error) -> Void) throws {
    self.terminationHandler = onError
    try self.process.run()
  }
}

public struct NgrokCLIAPI : Sendable {
  public init(ngrokPath: String) {
    self.ngrokPath = ngrokPath
  }
  
  let ngrokPath: String

  public func process(forHTTPPort port: Int) -> NgrokProcess {
    let process = Process()
    process.executableURL = .init(filePath: ngrokPath)
    process.arguments = ["http", port.description]
    return .init(process: process)
  }
}
