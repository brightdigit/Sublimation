import Sublimation
import Network
import SublimationDemoConfiguration
import SwiftUI

extension View {
  func taskPolyfill(_ action: @escaping @Sendable () async -> Void) -> some View {
    if #available(iOS 15.0, *) {
      return self.task(action)
    } else {
      return onAppear {
        Task {
          await action()
        }
      }
    }
  }
}

class AppModel {

    var browserQ: NWBrowser? = nil
    
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
                  dump(result.metadata)
                  print("+ \(result.endpoint)")
                  //dump(result.endpoint)
                case .removed(let result):
                    print("- \(result.endpoint)")
                case .changed(old: let old, new: let new, flags: _):
                  dump(new.metadata)
                    print("± \(old.endpoint) \(new.endpoint)")
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
  let model = AppModel()
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

  func getBaseURL(
    fromBucket bucketName: String,
    withKey key: String
  ) async throws -> URL {
    //self.model.
//    guard let url = try await KVdb.url(withKey: key, atBucket: bucketName) else {
    throw DemoError.noURLSetAt(bucketName, key)
//    }
//    return url
  }

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
      Text(serverResponse)
    }
    .padding()
    .taskPolyfill {
      let serverResponse: String
      do {
        let url = try await getBaseURL(
          fromBucket: Configuration.bucketName,
          withKey: Configuration.key
        )
        serverResponse = try await getServerResponse(from: url)
      } catch {
        serverResponse = error.localizedDescription
      }
      await MainActor.run {
        self.serverResponse = serverResponse
      }
    }
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
