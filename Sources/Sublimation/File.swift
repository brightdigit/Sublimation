//
//  File.swift
//  
//
//  Created by Leo Dion on 4/30/24.
//

import Foundation
import Network

enum URLScheme : String {
  case http
  case https
}

public final class NetworkExplorer : Sendable {
  let browser : NWBrowser
  let queue : DispatchQueue = .global()
  public private (set) var currentState : NWBrowser.State? = nil
  
  private var continuation : CheckedContinuation<[URL], Never>?
  private var urls : [URL]?
  
  public  convenience init(bonjourWithType type: String = "_http._tcp", domain: String = "local.", using parameters: NWParameters = .tcp) {
    self.init(for: .bonjourWithTXTRecord(type: type, domain: domain), using: parameters)
  }
  convenience init(for descriptor: NWBrowser.Descriptor, using parameters: NWParameters) {
    self.init(browser: .init(for: descriptor, using: parameters))
  }
   init(browser: NWBrowser) {
    self.browser = browser
    browser.stateUpdateHandler = {
      self.currentState = $0
    }
    browser.browseResultsChangedHandler = self.onResultsChanged(to:withChanges:)
  }
  
  func urls(from result: NWBrowser.Result) -> [URL]? {
    guard case let .service(key, _, _, _) = result.endpoint else {
      return nil
    }
    guard case let .bonjour(txtRecord) =  result.metadata else {
      return nil
    }
    var offset  = 0
    var port = 80
    var isTLS = false
    if case let .string(newPort) = txtRecord.getEntry(for: "Sublimation_Port") {
      port = Int(newPort) ?? port
      offset += 1
    }
    if case let .string(boolValue) = txtRecord.getEntry(for: "Sublimation_TLS") {
      isTLS = Bool(boolValue) ?? isTLS
      offset += 1
    }
    let scheme = isTLS ? "https" : "http"
    let addressCount = txtRecord.count - offset
    return (0..<addressCount).compactMap { index -> URL? in
      let key = "Sublimation_Address_\(index)"
      guard case let .string(host) = txtRecord.getEntry(for: key) else {
        return nil
      }
      var components = URLComponents()
      components.scheme = scheme
      components.host = host
      components.port = port
      return components.url
    }
    
    
  }
  
  func parseResult(_ result: NWBrowser.Result) {
    
    guard let urls = urls(from: result) else {
      return
    }
    
      guard let continuation else {
        self.urls = urls
        return
      }
    continuation.resume(returning: urls)
    browser.stateUpdateHandler = nil
    browser.cancel()
  }
  
  func onResultsChanged (to newResults: Set<NWBrowser.Result>, withChanges changes: Set<NWBrowser.Result.Change>) {
    for change in changes {
      switch change {
        
      case .added(let result):
        parseResult(result)
        break
      case .removed(_):
        break
      case .changed(old: let old, new: let new, flags: .metadataChanged):
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
  
  public func urls () async -> [URL] {
    if let urls {
      return urls
    }
    browser.start(queue: self.queue)
    return await withCheckedContinuation { continuation in
      self.continuation = continuation
    }
  }
}
