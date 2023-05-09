import Foundation
import Prch
import PrchModel

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum Ngrok {
  
  public enum API : BaseAPI {
    public static let encoder: any PrchModel.Encoder<Data> = JSONEncoder()
    
    public static let decoder: any PrchModel.Decoder<Data> = JSONDecoder()
    
    public typealias DataType = Data
    
    public static let baseURLComponents = URLComponents(string: "http://127.0.0.1:4040")!
    
    public static let headers: [String : String] = [:]
    
    
  }
//  public struct API {
//    public init(coder: any Coder<Data> = JSONCoder(encoder: .init(), decoder: .init()), authorizationManager: (any AuthorizationManager)? = nil, baseURLComponents: URLComponents = Self.defaultBaseURLComponents) {
//      self.coder = coder
//      self.authorizationManager = authorizationManager ?? NullAuthorizationManager()
//      self.baseURLComponents = baseURLComponents
//    }
//    
//    
//    public var coder: any Coder<Data>
//    
//    public var authorizationManager: any AuthorizationManager
//    
//    public static let defaultBaseURLComponents = URLComponents(string: "http://127.0.0.1:4040")!
//
//
//    public let baseURLComponents: URLComponents
//
//    public let headers = [String: String]()
//
//    public enum Error: Swift.Error {
//      case tunnelNotFound
//    }
//  }

  public struct CLI {
    static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
    public init(executableURL: URL) {
      self.executableURL = executableURL
    }

    let executableURL: URL

    public enum RunError: Error {
      case earlyTermination(Process.TerminationReason, Int?)
      case invalidErrorData(Data)
    }

    private func processTerminated(_: Process) {}

    public func http(port: Int, timeout: DispatchTime) async throws -> Process {
      let process = Process()
      let pipe = Pipe()
      let semaphore = DispatchSemaphore(value: 0)
      process.executableURL = executableURL
      process.arguments = ["http", port.description]
      process.standardError = pipe
      process.terminationHandler = { _ in
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
        let errorCode: Int?

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
