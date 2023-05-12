import Sublimation
import SublimationDemoConfiguration
import SwiftUI

extension View {
  func taskPolyfill(_ action: @escaping @Sendable() async -> Void) -> some View {
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

struct ContentView: View {
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
    guard let url = try await KVdb.url(withKey: key, atBucket: bucketName) else {
      throw DemoError.noURLSetAt(bucketName, key)
    }
    return url
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
      Text(self.serverResponse)
    }
    .padding()
    .taskPolyfill {
      let serverResponse: String
      do {
        let url = try await self.getBaseURL(
          fromBucket: Configuration.bucketName,
          withKey: Configuration.key
        )
        serverResponse = try await self.getServerResponse(from: url)
      } catch {
        serverResponse = error.localizedDescription
      }
      await MainActor.run {
        self.serverResponse = serverResponse
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
