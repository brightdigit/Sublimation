import Ngrokit
import OpenAPIAsyncHTTPClient
import Sublimation
import Vapor
import OpenAPIRuntime
import AsyncHTTPClient

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif


public final class SublimationLifecycleHandler<
  TunnelRepositoryType: WritableTunnelRepository,
  NgrokServerFactoryType : NgrokServerFactory
>: LifecycleHandler, NgrokServerDelegate where NgrokServerFactoryType.Configuration : NgrokVaporConfiguration {
  private actor LoggerContainer {
    var logger: Logger?

    func setLogger(_ logger: Logger) {
      self.logger = logger
    }
  }

  public func server(_: any NgrokServer, updatedTunnel tunnel: Tunnel) {
    Task {
      do {
        try await self.tunnelRepo.saveURL(tunnel.publicURL, withKey: self.key)
      } catch {
        await self.getLogger()?.error(
          "Unable to save url to repository: \(error.localizedDescription)"
        )
        return
      }
      await self.getLogger()?.notice(
        "Saved url \(tunnel.publicURL) to repository with key \(self.key)"
      )
    }
  }

  public func server(_: any NgrokServer, errorDidOccur _: any Error) {}

  public func server(_: any NgrokServer, failedWithError _: any Error) {}

  public init(
    factory: NgrokServerFactoryType,
    repo: TunnelRepositoryType,
    key: TunnelRepositoryType.Key
  ) {
    self.factory = factory
    tunnelRepo = repo
    self.key = key
  }

  var server: (any NgrokServer)?
  let factory: NgrokServerFactoryType
  let tunnelRepo: TunnelRepositoryType
  let key: TunnelRepositoryType.Key
  private func getLogger() async -> Logger? {
    await loggerContainer.logger
  }

  private let loggerContainer = LoggerContainer()

  public func willBoot(_ application: Application) throws {
    
    let server = factory.server(
      from: NgrokServerFactoryType.Configuration.init(application: application),
      handler: self
    )
    self.server = server
    server.start()
//    Task {
//      do {
//        try await Task.sleep(for: .seconds(1), tolerance: .seconds(3))
//      } catch {
//        application.logger.log(
//          level: .error,
//          "Could not sleep \(error.localizedDescription)"
//        )
//      }
//      await self.loggerContainer.setLogger(application.logger)
//      await server.startTunnelFor(application: application, withDelegate: self)
//      await tunnelRepo.setupClient(
//        VaporTunnelClient(
//          client: application.client,
//          keyType: TunnelRepositoryType.Key.self
//        )
//      )
//    }
    // logger = application.logger
  }

  public func shutdown(_: Application) {}
}

enum NetworkResult<T> {
  case success(T)
  case connectionRefused(ClientError)
  case failure(any Error)
}

extension FileHandle {
  
  // swiftlint:disable:next force_try
  static let errorRegex = try! NSRegularExpression(pattern: "ERR_NGROK_([0-9]+)")
  func parseNgrokErrorCode() throws -> Int? {
    guard let data = try readToEnd() else {
      return nil
    }

    guard let text = String(data: data, encoding: .utf8) else {
      throw RuntimeError.invalidErrorData(data)
    }

    guard let match = FileHandle.errorRegex.firstMatch(
      in: text,
      range: .init(location: 0, length: text.count)
    ), match.numberOfRanges > 0 else {
      return nil
    }

    guard let range = Range(match.range(at: 1), in: text) else {
      return nil
    }
    return Int(text[range])
  }
}


extension NetworkResult {
  
  init (error: any Error) {
    guard let error = error as? ClientError else {
      self = .failure(error)
      return
    }
    
    guard let posixError = error.underlyingError as? HTTPClient.NWPOSIXError else {
      self = .failure(error)
      return
    }
    
    guard posixError.errorCode == .ECONNREFUSED else {
      self = .failure(error)
      return
    }
    
    self = .connectionRefused(error)
  }
  
  init (_ closure: @escaping () async throws -> T) async {
    do {
      self = try await .success(closure())
    } catch {
      self = .init(error: error)
    }
  }
  
  func get () throws -> T?{
    switch self {
    case .connectionRefused(_):
      return nil
    case .failure(let error):
      throw error
    case .success(let item):
      return item
    }
  }
}
extension Process {
  func run (_ terminationHandler: @Sendable @escaping (Process) -> Void) throws {
    self.terminationHandler = terminationHandler
    try self.run()
  }
}

public struct NgrokCLIAPIServer : NgrokServer, Sendable {
  internal init(
    delegate: any NgrokServerDelegate,
    client: Ngrok.Client,
    process: Process,
    port: Int,
    logger: Logger
  ) {
    self.delegate = delegate
    self.client = client
    self.pipe = Pipe()
    self.process = process
    self.port = port
    self.logger = logger
    
    self.process.terminationHandler = self.terminationHandler(_:)
    self.process.standardError = pipe
  }
  
  let delegate : any NgrokServerDelegate
  let client : Ngrok.Client
  let process: Process
  let port: Int
  let pipe : Pipe
  let logger : Logger
  
  func cliError(_ error: any Error) {
    self.delegate.server(self, errorDidOccur: error)
  }
  
  @Sendable
  func terminationHandler (_ process: (Process)) {
    logger.debug("Process Terminated.")
    let errorCode: Int?
    
    do {
      errorCode = try pipe.fileHandleForReading.parseNgrokErrorCode()
    } catch {
      
      cliError(error)
      return
    }
    cliError(RuntimeError.earlyTermination(process.terminationReason, errorCode))
  }
  
  func searchForExistingTunnel (within timeout: TimeInterval) async throws -> Tunnel? {
    logger.debug("Starting Search for Existing Tunnel")
    let result = await NetworkResult {
      try await self.client.listTunnels().first
    }
    
    switch result {
    case .connectionRefused:
      logger.debug("Ngrok not started. Running Process.")
      try process.run()
      try await Task.sleep(for: .seconds(1), tolerance: .seconds(1))
    case .success(let tunnel):
      logger.debug("Process Already Running.")
      return tunnel
    case .failure(let error):
      throw error
    }
    
   
   
    
    // start cli command
    let start = Date()
    var networkResult : NetworkResult<Tunnel?>?
    var lastError : ClientError?
    var attempts = 0
    while networkResult == nil, (-start.timeIntervalSinceNow) < timeout {
      logger.debug("Attempt #\(attempts + 1)")
         networkResult = await NetworkResult{
          try await self.client.listTunnels().first
        }
      attempts += 1
        switch networkResult {
        case .connectionRefused(let error):
          lastError = error
          networkResult = nil
        default:
          continue
        }
      }
    
    if let lastError, networkResult == nil {
      logger.debug("Timeout Occured After \(-start.timeIntervalSinceNow) seconds.")
     throw lastError
      
    }
    
      return try networkResult?.get()?.flatMap({$0})
    
  }
  
  public func run () async {
    
    
    
    let newTunnel : Tunnel
    do {
      if let oldTunnel = try await self.searchForExistingTunnel(within: 30.0) {
        logger.debug("Existing Tunnel Found. \(oldTunnel.publicURL)")
        try await self.client.stopTunnel(withName: oldTunnel.name)
        logger.debug("Tunnel Stopped.")
      }
      
      newTunnel = try await self.client.startTunnel(
        .init(
          port: port,
          name: "vapor-development"
        )
      )
    } catch {
      self.delegate.server(self, failedWithError: error)
      return
    }
    logger.debug("New Tunnel Created. \(newTunnel.publicURL)")
    
    self.delegate.server(self, updatedTunnel: newTunnel)
    
    // periodically check for tunnel
      // if succeed let vapor know
      // if fails non-refused let vapor know
    
      
    // if there's a tunnel
      // delete existing
    
    // start new one
    
  }
  public func start() {
    Task {
      await self.run()
    }
  }
  
  
}
public struct NgrokCLIAPIConfiguration : NgrokServerConfiguration {
  public typealias Server = NgrokCLIAPIServer
  let port : Int
  let logger : Logger
}
public protocol NgrokVaporConfiguration : NgrokServerConfiguration {
  init (application: Application)
}
extension NgrokCLIAPIConfiguration : NgrokVaporConfiguration {
  public init(application: Application) {
    self.init(
      port: application.http.server.configuration.port,
      logger: application.logger
    )
  }
}

public protocol NgrokServerConfiguration {
  associatedtype Server : NgrokServer
}
public struct NgrokCLIAPIServerFactory : NgrokServerFactory {
  let ngrokPath: String
  
  public typealias Configuration = NgrokCLIAPIConfiguration
  
  
  public func server(from configuration: Configuration, handler: any NgrokServerDelegate) -> NgrokCLIAPIServer {
    let client = Ngrok.Client(transport: AsyncHTTPClientTransport())
    
    let process = Process()
    process.executableURL = .init(filePath: self.ngrokPath)
    process.arguments = ["http", configuration.port.description]
    return .init(
      delegate: handler,
      client: client,
      process: process,
      port: configuration.port,
      logger: configuration.logger
    )
  }
}

public protocol NgrokServerFactory {
  associatedtype Configuration : NgrokServerConfiguration
  
  func server(from configuration: Configuration,  handler: any NgrokServerDelegate) -> Configuration.Server
}
#if os(macOS)
  extension SublimationLifecycleHandler {
    public convenience init<Key>(
      ngrokPath: String,
      bucketName: String,
      key: Key
    ) where TunnelRepositoryType == KVdbTunnelRepository<Key>, NgrokServerFactoryType == NgrokCLIAPIServerFactory {
      self.init(
        factory: NgrokCLIAPIServerFactory(ngrokPath: ngrokPath),
        repo: .init(bucketName: bucketName),
        key: key
      )
    }
  }
#endif
