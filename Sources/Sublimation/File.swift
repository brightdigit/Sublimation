//
//  File.swift
//  
//
//  Created by Leo Dion on 4/30/24.
//

import Foundation
import Network
@preconcurrency import os.log

enum URLScheme : String {
  case http
  case https
}

//public struct PrefixContinuation<Element> {
//  var elements = [Element]()
//  var continuation : AsyncStream<Element>.Continuation?
//}
//public final class BonjourServerFinder {
//  let browser : NWBrowser
//  let queue : DispatchQueue
//  
//  var continuation : AsyncStream<Server>.Continuation?
//  public  convenience init(bonjourWithType type: String = "_http._tcp", domain: String = "local.", using parameters: NWParameters = .tcp, queue: DispatchQueue = .global(), autoStart : Bool = false) {
//    self.init(for: .bonjourWithTXTRecord(type: type, domain: domain), using: parameters)
//  }
//  convenience init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters, queue: DispatchQueue = .global(), autoStart : Bool = false) {
//    self.init(browser: .init(for: descriptor, using: parameters))
//  }
//  init(browser: NWBrowser, queue: DispatchQueue = .global(), autoStart : Bool = false) {
//    self.browser = browser
//    self.queue = queue
//  }
//  public func servers () -> AsyncStream<Server> {
//    return AsyncStream { continuation in
//      
//    }
//  }
//}
//public struct Server {
//  public let hosts : [String]
//  public let isTLS : Bool
//  public let port : Int
//}

private actor NetworkBrowser {
  public init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters) {
    let browser = NWBrowser(for: descriptor, using: parameters)
    self.init(browser: browser)
    browser.stateUpdateHandler = { state in
      Task {
        await self.onUpdateState(state)
      }
    }
    browser.browseResultsChangedHandler = { newResults, changes in
      Task {
        await self.onResultsChanged(to: newResults, withChanges: changes)
      }
    }
  }

  private init(browser: NWBrowser) {
    self.browser = browser
  }
  
  func start(queue: DispatchQueue, parser: @Sendable @escaping (NWBrowser.Result) -> Void) {
    self.browser.start(queue: queue)
    self.parseResult = parser
  }
  func onUpdateState (_ state: NWBrowser.State) {
    self.currentState = state
  }
  func onResultsChanged (to newResults: Set<NWBrowser.Result>, withChanges changes: Set<NWBrowser.Result.Change>) {
    guard let parseResult else {
      return
    }
    for change in changes {
      switch change {
        
      case .added(let result):
        parseResult(result)
        break
      case .removed(_):
        break
      case .changed(old: _, new: let new, flags: .metadataChanged):
        parseResult(new)
        break
      case .identical:
        break
      case .changed:
        break
      @unknown default:
        break
      }
    }
  }
  
  func stop () {
    self.browser.stateUpdateHandler = nil
    self.browser.cancel()
  }
  
  var currentState : NWBrowser.State?
  let browser : NWBrowser
  var parseResult : ((NWBrowser.Result) -> Void)?
}

private actor StreamManager {
  private var streamContinuations = [UUID: AsyncStream<URL>.Continuation]()
  
  func yield(_ urls: [URL], logger: Logger?) {
    if streamContinuations.isEmpty {
      
      logger?.debug("Missing Continuations.")
    }
    for streamContinuation in streamContinuations {
  
    for url in urls {
      streamContinuation.value.yield(url)
    }
      logger?.debug("Yielded to Stream \(streamContinuation.key)")
  }
  }
  
  private func onTerminationOf(_ id: UUID) -> Bool {
    self.streamContinuations.removeValue(forKey: id)
    return self.streamContinuations.isEmpty
  }
  
  public var isEmpty : Bool {
    return streamContinuations.isEmpty
  }
  
  public func append(_ continuation: AsyncStream<URL>.Continuation, onCancel: @Sendable @escaping () async -> Void) {
    let id = UUID()
    self.streamContinuations[id] = continuation
    continuation.onTermination = { termination in
      //self.logger?.debug("Removing Stream \(id)")
      Task {
        let shouldCancel =
        await self.onTerminationOf(id)
        
        //self.streamContinuations.removeValue(forKey: id)
        
        if shouldCancel {
          await onCancel()
        }
      }
    }
  }
}
public final actor NetworkExplorer {
#warning("Add Logger")
  private let browser : NetworkBrowser
  let queue : DispatchQueue = .global()
  nonisolated let logger : Logger?
  private let streams = StreamManager()
  //private let browserState = BrowserState()
  //private let urls : AsyncStream<URL>
  //private var streamContinuations = [UUID: AsyncStream<URL>.Continuation]()
  //public private (set) var currentState : NWBrowser.State? = nil
  //var hasSetupBrowser : Bool = false
  
  public  init(bonjourWithType type: String = "_http._tcp", domain: String = "local.", using parameters: NWParameters = .tcp, logger: Logger?) {
    self.init(for: .bonjourWithTXTRecord(type: type, domain: domain), using: parameters, logger: logger)
  }
   init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters, logger : Logger?) {
    self.init(browser: .init(for: descriptor, using: parameters), logger: logger)
  }
  private init(browser: NetworkBrowser, logger: Logger?) {
    self.logger = logger
    self.browser = browser
    
  }
  
  
//  private func onUpdateState(_ state: NWBrowser.State) {
//    Task {
//    
//      self.updateState(state)
//      self.logger?.debug("State changed.")
//    }
//  }
  
  private static func urls(from result: NWBrowser.Result, logger: Logger?) -> [URL]? {
    guard case .service(_, _, _, _) = result.endpoint else {
      logger?.debug("Not service.")
      return nil
    }
    guard case let .bonjour(txtRecord) =  result.metadata else {
      logger?.debug("No txt record.")
      return nil
    }
    var offset  = 0
    var port = 80
    var isTLS = false
    #warning("Store Keys in Constants")
    if case let .string(newPort) = txtRecord.getEntry(for: "Sublimation_Port") {
      port = Int(newPort) ?? port
      logger?.debug("Found port: \(port)")
      offset += 1
    }
    if case let .string(boolValue) = txtRecord.getEntry(for: "Sublimation_TLS") {
      isTLS = Bool(boolValue) ?? isTLS
      logger?.debug("Found TLS: \(isTLS)")
      offset += 1
    }
    let scheme = isTLS ? "https" : "http"
    logger?.debug("Scheme: \(scheme)")
    let addressCount = txtRecord.count - offset
    logger?.debug("Parsing \(addressCount) Addresses")
    return (0..<addressCount).compactMap { index -> URL? in
      let key = "Sublimation_Address_\(index)"
      guard case let .string(host) = txtRecord.getEntry(for: key) else {
        logger?.debug("Invalid Address At Index: \(index)")
        return nil
      }
      var components = URLComponents()
      components.scheme = scheme
      components.host = host
      components.port = port
      return components.url
    }
    
  }
  
  
  private func parseResult(_ result: NWBrowser.Result) {
    guard let urls = Self.urls(from: result, logger: self.logger) else {
      return
    }
    let logger = self.logger
    let streams = self.streams
    Task {
      await streams.yield(urls, logger: logger)
    }

  }
  


  
  public var urls: AsyncStream<URL> {
     get async{
       let browser = self.browser
       let streams = self.streams
       let parseResult = self.parseResult
       if await self.streams.isEmpty {
      self.logger?.debug("Starting Browser.")

         await browser.start(queue: self.queue, parser:  {
           parseResult($0)
         })
    }
       return AsyncStream { continuation in
         Task {
         await streams.append(continuation) {
             await browser.stop()
             self.logger?.debug("Shuting down browser.")
           }
         }
       }
    }
  }
  
  
  
}
