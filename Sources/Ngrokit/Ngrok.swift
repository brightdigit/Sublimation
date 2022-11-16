import Foundation
import Prch

public enum Ngrok {
  public struct API : Prch.API {
    public static let defaultBaseURL = URL(staticString: "http://127.0.0.1:4040")
    public init(baseURL: URL = Self.defaultBaseURL, encoder: RequestEncoder = JSONEncoder()) {
      self.baseURL = baseURL
      self.encoder = encoder
    }
    
    
    public let baseURL: URL
    
    public let headers = [String : String]()
    
    public let decoder : ResponseDecoder = JSONDecoder()
    
    public var encoder : RequestEncoder = JSONEncoder()
    
    public enum Error : Swift.Error {
      case tunnelNotFound
    }
  }
  
  
  public struct CLI {
    static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
    public init(executableURL: URL) {
      self.executableURL = executableURL
    }
    
    let executableURL : URL
    
    public enum RunError : Error {
      case earlyTermination(Process.TerminationReason, Int?)
      case invalidErrorData(Data)
    }
    
    private func processTerminated(_ process: Process) {
      
    }
    
    
    public func http(port: Int, timeout: DispatchTime) async throws -> Process {
      
      let process = Process()
      let pipe = Pipe()
      let semaphore = DispatchSemaphore(value: 0)
      process.executableURL = executableURL
      process.arguments = ["http", port.description]
      process.standardError = pipe
      process.terminationHandler = { process in
        semaphore.signal()
      }
      try process.run()
      return try await withCheckedThrowingContinuation { continuation in
        let semaphoreResult = semaphore.wait(timeout: timeout)
        guard semaphoreResult == .success else {
          process.terminationHandler = nil
          continuation.resume(returning: process)
          return
        }
        let errorCode : Int?
        
        do {
          errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
        } catch {
          continuation.resume(with: .failure(error))
          return
        }
        continuation.resume(with: .failure(RunError.earlyTermination(process.terminationReason, errorCode)))
      }
    }
  }
}

