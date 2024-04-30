import Foundation
import Network
import Observation

public struct AvailableService {
  public  init(key: String, baseURL: URL) {
    self.key = key
    self.baseURL = baseURL
  }
  
  public let key : String
  public let baseURL : URL
}

extension AvailableService {
  public init?(result: NWBrowser.Result) {
    guard case let .service(key, _, _, _) = result.endpoint else {
      return nil
    }
    guard case let .bonjour(txtRecord) =  result.metadata else {
      return nil
    }
    guard case let .string(urlString) = txtRecord.getEntry(for: "Sublimation") else {
      return nil
    }
    guard let baseURL = URL(string: urlString) else {
      return nil
    }
    self.init(key: key, baseURL: baseURL)
  }
}
@Observable
public class AppModel {
  public init(browserQ: NWBrowser? = nil, availableService: AvailableService? = nil) {
    self.browserQ = browserQ
    self.availableService = availableService
  }
  

  @ObservationIgnored
    var browserQ: NWBrowser? = nil
  
  public private(set) var availableService : AvailableService?
    
    func start() -> NWBrowser {
        print("browser will start")
      
      
        let descriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(type: "_http._tcp", domain: "local.")
      let browser = NWBrowser(for: descriptor, using: .tcp)
      
        browser.stateUpdateHandler = { newState in
            print("browser did change state, new: \(newState)")
        }
        browser.browseResultsChangedHandler = { updated, changes in
            print("browser results did change:")
            for change in changes {
                switch change {
                case .added(let result):
                  dump(result)
                  if let service = AvailableService(result: result) {
                    if let availableService = self.availableService, availableService.key == service.key {
                      self.availableService = service
                    } else {
                      self.availableService = service
                    }
                  }
                case .removed(let result):
                  
                  if let service = AvailableService(result: result) {
                    if self.availableService?.key == service.key {
                      self.availableService = nil
                    }
                  }
                case .changed(old: let old, new: let new, flags: .metadataChanged):
                  if let oldService = AvailableService(result: old), let newService = AvailableService(result: new), oldService.key == self.availableService?.key {
                    self.availableService = newService
                  } else if let newService = AvailableService(result: new), self.availableService == nil {
                    self.availableService = newService
                  }
                case .changed(old: let old, new: let new, flags: let flags):
                    print("± \(old.endpoint) \(new.endpoint) \(flags)")
                case .identical:
                    fallthrough
                @unknown default:
                    print("?")
                }
            }
        }
        browser.start(queue: .main)
        return browser
    }
    
    func stop(browser: NWBrowser) {
        print("browser will stop")
        browser.stateUpdateHandler = nil
        browser.cancel()
    }
    
    public func startStop() {
        if let browser = self.browserQ {
            self.browserQ = nil
            self.stop(browser: browser)
        } else {
            self.browserQ = self.start()
        }
    }
}
