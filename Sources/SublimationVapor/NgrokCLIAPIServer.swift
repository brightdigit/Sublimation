import Foundation
import Ngrokit

//import class Prch.Client
import PrchVapor
import Vapor
import Prch
import PrchModel
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif


enum NgrokDefaults {
    public static let defaultBaseURLComponents = URLComponents(string: "http://127.0.0.1:4040")!
}

protocol NgrokServiceProtocol : ServiceProtocol where ServiceAPI == Ngrok.API {
  
}

class NgrokService<SessionType : Prch.Session> : Service, NgrokServiceProtocol where SessionType.ResponseType.DataType == Ngrok.API.ResponseDataType,
                                                                                           SessionType.RequestDataType == Ngrok.API.RequestDataType {

  

  internal init(session: SessionType) {
    self.session = session
  }
  
  
  let session: SessionType
  
  
  var authorizationManager: any SessionAuthenticationManager {
    return NullAuthorizationManager()
  }
  
  typealias API = Ngrok.API
  
  var api: Ngrok.API {
    Ngrok.API.shared
  }
}
//class NgrokService<SessionType : Prch.Session> : Service where SessionType.ResponseType.DataType == Data {
//  var authorizationManager: any SessionAuthenticationManager {
//    return self._authorizationManager
//  }
//
//  var coder: any PrchModel.Coder<SessionType.ResponseType.DataType> {
//    return self._coder
//  }
//
//  internal init(session: SessionType) {
//    self.session = session
//    self.baseURLComponents = NgrokDefaults.defaultBaseURLComponents
//    //self.authorizationManager = authorizationManager ?? NullAuthorizationManager()
//    self.headers = [:]
//  }
//
//
//  @available(macOS 13.0.0, *)
//  internal init(session: SessionType, coder: (any Coder<Data>)? = nil, baseURLComponents: URLComponents = NgrokDefaults.defaultBaseURLComponents , headers: [String : String] = [:]) {
//    self.session = session
//    self.baseURLComponents = baseURLComponents
//    //self.authorizationManager = authorizationManager ?? NullAuthorizationManager()
//    self.headers = headers
//  }
//
//  var session: SessionType
//
//  let _coder: some Coder<SessionType.ResponseType.DataType> = JSONCoder(encoder: .init(), decoder: .init())
//
//
//
//  var baseURLComponents: URLComponents
//
//  let _authorizationManager = NullAuthorizationManager<SessionType.AuthorizationType>()
//
//  var headers: [String : String]
//
//
//}
//
//class Client<SessionType : Prch.Session> : Service {
//  var authorizationManager: any AuthorizationManager
//  
//  let coder: any Coder<Data>
//  
//  let session: SessionType
//  
//  let baseURLComponents: URLComponents
//  
//  
//  let headers: [String : String]
//  
//  init(authorizationManager: any SessionAuthenticationManager, coder: any Coder<Data>, session: SessionType, baseURLComponents: URLComponents, headers: [String : String]) {
//    self.authorizationManager = authorizationManager
//    self.coder = coder
//    self.session = session
//    self.baseURLComponents = baseURLComponents
//    self.headers = headers
//  }
//
//}

class NgrokCLIAPIServer: NgrokServer {
  internal init(cli: Ngrok.CLI, prchClient: (any NgrokServiceProtocol)? = nil, port: Int? = nil, logger: Logger? = nil, ngrokProcess: Process? = nil, clientSearchTimeoutNanoseconds: UInt64 = NSEC_PER_SEC / 5, cliProcessTimeout: DispatchTimeInterval = .seconds(2), delegate: NgrokServerDelegate? = nil) {
    self.cli = cli
    self._prchClient = prchClient
    self.port = port
    self.logger = logger
    self.ngrokProcess = ngrokProcess
    self.cliProcessTimeout = cliProcessTimeout
    self.clientSearchTimeoutNanoseconds = clientSearchTimeoutNanoseconds
    self.delegate = delegate
  }

  public convenience init(ngrokPath: String, prchClient: (any NgrokServiceProtocol)? = nil, port: Int? = nil, logger: Logger? = nil, ngrokProcess: Process? = nil, delegate: NgrokServerDelegate? = nil) {
    self.init(cli: .init(executableURL: .init(fileURLWithPath: ngrokPath)), prchClient: prchClient, port: port, logger: logger, ngrokProcess: ngrokProcess, delegate: delegate)
  }

  let cli: Ngrok.CLI
  let clientSearchTimeoutNanoseconds: UInt64
  let cliProcessTimeout: DispatchTimeInterval
  var _prchClient: (any NgrokServiceProtocol)?
  var port: Int?
  var logger: Logger!
  var ngrokProcess: Process? {
    didSet {
      self.ngrokProcess?.terminationHandler = self.ngrokProcessTerminated
    }
  }

  weak var delegate: NgrokServerDelegate?

  func setupLogger(_ logger: Logger) {
    self.logger = logger
  }

  func ngrokProcessTerminated(_: Process) {
    guard let port = self.port else {
      return
    }

    self.startHttpTunnel(port: port)
  }
  
  var prchClient : any NgrokServiceProtocol {
    guard let client = _prchClient  else {
      fatalError()
    }
    return client
  }

  func setupClient(_ client: Vapor.Client) {
    let service = NgrokService(session: SessionClient(client: client))
    self._prchClient = service
  }

  public enum TunnelError: Error {
    case noTunnelCreated
  }

  func startHttpTunnel(port: Int) {
    Task {
      let tunnel: NgrokTunnel
      do {
        tunnel = try await self.startHttp(port: port)
      } catch {
        self.delegate?.server(self, failedWithError: error)
        return
      }
      self.delegate?.server(self, updatedTunnel: tunnel)
    }
  }

  public func waitForTaskCompletion<R>(
    withTimeoutInNanoseconds timeout: UInt64,
    _ task: @escaping () async -> R
  ) async -> R? {
    await withTaskGroup(of: R?.self) { group in
      await withUnsafeContinuation { continuation in
        group.addTask {
          continuation.resume()
          return await task()
        }
      }
      group.addTask {
        await Task.yield()
        try? await Task.sleep(nanoseconds: timeout)
        return nil
      }
      defer { group.cancelAll() }
      return await group.next()!
    }
  }

  func startHttp(port: Int) async throws -> NgrokTunnel {
    self.port = port
    self.logger.debug("Starting Ngrok Tunnel...")
    let tunnels: [NgrokTunnel]

    let result = await waitForTaskCompletion(withTimeoutInNanoseconds: self.clientSearchTimeoutNanoseconds) {
      
      //self.prchClient.request(ListTunnelsRequest())
      try? await self.prchClient.request(ListTunnelsRequest()).tunnels
    }?.flatMap { $0 }

    if let firstCallTunnels = result {
      tunnels = firstCallTunnels
    } else {
      do {
        self.logger.debug("Starting New Ngrok Client")
        let ngrokProcess = try await cli.http(port: port, timeout: .now() + self.cliProcessTimeout)
        guard let tunnel = try await self.prchClient.request(ListTunnelsRequest()).tunnels.first else {
          ngrokProcess.terminate()
          throw TunnelError.noTunnelCreated
        }
        self.ngrokProcess = ngrokProcess
        self.logger.debug("Created Ngrok Process...")
        return tunnel
      } catch let Ngrok.CLI.RunError.earlyTermination(_, errorCode) where errorCode == 108 {
        self.logger.debug("Ngrok Process Already Created.")
      } catch {
        self.logger.debug("Error thrown: \(error.localizedDescription)")
        throw error
      }

      self.logger.debug("Listing Tunnels")
      tunnels = try await prchClient.request(ListTunnelsRequest()).tunnels
    }

    if let oldTunnel = tunnels.first {
      self.logger.debug("Deleting Existing Tunnel: \(oldTunnel.public_url) ")
      try await prchClient.request(StopTunnelRequest(name: oldTunnel.name))
    }

    self.logger.debug("Creating Tunnel...")
    let tunnel = try await prchClient.request(StartTunnelRequest(body: .init(port: port)))

    return tunnel
  }
}
