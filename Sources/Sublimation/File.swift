//
//  File.swift
//  
//
//  Created by Leo Dion on 4/30/24.
//

import Foundation
import Network


final class NetworkExplorer : Sendable {
  let browser : NWBrowser
  let queue : DispatchQueue = .global()
  public private (set) var currentState : NWBrowser.State? = nil
  
  private var continuation : CheckedContinuation<[URL], Never>?
  
  init(browser: NWBrowser) {
    self.browser = browser
    browser.stateUpdateHandler = {
      self.currentState = $0
    }
    browser.browseResultsChangedHandler = self.onResultsChanged(to:withChanges:)
  }
  
  func onResultsChanged (to newResults: Set<NWBrowser.Result>, withChanges changes: Set<NWBrowser.Result.Change>) {
    for change in changes {
      switch change {
        
      case .added(let result):
        break
      case .removed(_):
        break
      case .changed(old: let old, new: let new, flags: .metadataChanged):
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
  
  func urls () async -> [URL] {
    browser.start(queue: self.queue)
    return await withCheckedContinuation { continuation in
      self.continuation = continuation
    }
  }
}
