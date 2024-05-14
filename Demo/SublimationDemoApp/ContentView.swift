import Sublimation
import Network
import SublimationDemoConfiguration
import SwiftUI

struct ContentView: View {
  let networkExplorer = NetworkExplorer(logger: .init(subsystem: Bundle.main.bundleIdentifier!, category: "bonjour"))
  @State var baseURL: String = ""
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
      Text(self.baseURL)
      Text(serverResponse)
    }
    .padding()
    .onAppear(perform: {
      Task {
        for await baseURL in await networkExplorer.urls {
          var shouldCancel = false
          let serverResponse: String
          do {
            serverResponse = try await getServerResponse(from: baseURL)
            shouldCancel = true
          } catch {
            serverResponse = error.localizedDescription
          }
          await MainActor.run {
            self.baseURL = baseURL.absoluteString
            self.serverResponse = serverResponse
          }
          if shouldCancel {
            break
          }
        }
      }
    })
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
