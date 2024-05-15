//
//  AppModel.swift
//  Sublimation
//
//  Created by Leo Dion.
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
import Network
import Observation

//
// @available(*, deprecated)
// @Observable
// public class AppModel {
//  public init(browserQ: NWBrowser? = nil, availableService: AvailableService? = nil) {
//    self.browserQ = browserQ
//    self.availableService = availableService
//  }
//
//
//  @ObservationIgnored
//    var browserQ: NWBrowser? = nil
//
//  public private(set) var availableService : AvailableService?
//
//    func start() -> NWBrowser {
//        print("browser will start")
//
//
//        let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(type: "_http._tcp", domain: "local.")
//      let browser = NWBrowser(for: descriptor, using: .tcp)
//
//        browser.stateUpdateHandler = { newState in
//            print("browser did change state, new: \(newState)")
//        }
//        browser.browseResultsChangedHandler = { updated, changes in
//            print("browser results did change:")
//            for change in changes {
//                switch change {
//                case .added(let result):
//                  dump(result)
//                  if let service = AvailableService(result: result) {
//                    if let availableService = self.availableService, availableService.key == service.key {
//                      self.availableService = service
//                    } else {
//                      self.availableService = service
//                    }
//                  }
//                case .removed(let result):
//
//                  if let service = AvailableService(result: result) {
//                    if self.availableService?.key == service.key {
//                      self.availableService = nil
//                    }
//                  }
//                case .changed(old: let old, new: let new, flags: .metadataChanged):
//                  if let oldService = AvailableService(result: old), let newService = AvailableService(result: new), oldService.key == self.availableService?.key {
//                    self.availableService = newService
//                  } else if let newService = AvailableService(result: new), self.availableService == nil {
//                    self.availableService = newService
//                  }
//                case .changed(old: let old, new: let new, flags: let flags):
//                    print("± \(old.endpoint) \(new.endpoint) \(flags)")
//                case .identical:
//                    fallthrough
//                @unknown default:
//                    print("?")
//                }
//            }
//        }
//        browser.start(queue: .main)
//        return browser
//    }
//
//    func stop(browser: NWBrowser) {
//        print("browser will stop")
//        browser.stateUpdateHandler = nil
//        browser.cancel()
//    }
//
//    public func startStop() {
//        if let browser = self.browserQ {
//            self.browserQ = nil
//            self.stop(browser: browser)
//        } else {
//            self.browserQ = self.start()
//        }
//    }
// }
