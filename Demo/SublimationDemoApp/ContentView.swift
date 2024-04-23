import Sublimation
import Network
import SublimationDemoConfiguration
import SwiftUI



struct AvailableService {
  internal init(key: String, baseURL: URL) {
    self.key = key
    self.baseURL = baseURL
  }
  
  let key : String
  let baseURL : URL
}

extension AvailableService {
  init?(result: NWBrowser.Result) {
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
class AppModel {

  @ObservationIgnored
    var browserQ: NWBrowser? = nil
  
  var availableService : AvailableService?
    
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
    
    func startStop() {
        if let browser = self.browserQ {
            self.browserQ = nil
            self.stop(browser: browser)
        } else {
            self.browserQ = self.start()
        }
    }
}

struct ContentView: View {
  var model = AppModel()
  @State var serverResponse: String = ""

  enum DemoError: LocalizedError {
    case noURLSetAt(String, String)
    case invalidStringData(Data)
    case invalidResponse(URLResponse)
    case httpErrorStatusCode(Int)

    var errorDescription: String? {
      switch self {
      case let .noURLSetAt(bucket, key):
        return "No URL Set at \(bucket) and \(key)"
      case let .invalidStringData(data):
        return "Invalid Data: \(data)"
      case let .invalidResponse(response):
        return "Invalid Response Object: \(response)"
      case let .httpErrorStatusCode(statusCode):
        return "HTTP Error Status Code: \(statusCode)"
      }
    }
  }

//  func getBaseURL(
//    fromBucket bucketName: String,
//    withKey key: String
//  ) async throws -> URL {
//    //self.model.
////    guard let url = try await KVdb.url(withKey: key, atBucket: bucketName) else {
//    throw DemoError.noURLSetAt(bucketName, key)
////    }
////    return url
//  }

  func getServerResponse(
    from url: URL,
    using session: URLSession = .shared,
    encoding: String.Encoding = .utf8
  ) async throws -> String {
    let (data, urlResponse) = try await session.data(from: url)
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      throw DemoError.invalidResponse(urlResponse)
    }
    guard httpResponse.statusCode / 100 == 2 else {
      throw DemoError.httpErrorStatusCode(httpResponse.statusCode)
    }
    guard let response = String(data: data, encoding: encoding) else {
      throw DemoError.invalidStringData(data)
    }
    return response
  }

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("\(self.model.availableService?.baseURL.absoluteString ?? "")")
      Text(serverResponse)
    }
    .padding()

    .task(id: self.model.availableService?.baseURL, {
      guard let baseURL = self.model.availableService?.baseURL else {
        return
      }
      let serverResponse: String
      do {
        serverResponse = try await getServerResponse(from: baseURL)
      } catch {
        serverResponse = error.localizedDescription
      }
      await MainActor.run {
        self.serverResponse = serverResponse
      }
    })

    .onAppear(perform: {
      model.startStop()
    })
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
