//
//  ContentView.swift
//  SublimationDemoApp
//
//  Created by Leo Dion on 11/14/22.
//

import SwiftUI
import Sublimation
import SublimationDemoConfiguration

struct ContentView: View {
  @State var serverResponse : String = ""
  
  enum DemoError : Error {
    case noURLSetAt(String, String)
    case invalidStringData(Data)
  }
  func getBaseURL (fromBucket bucketName: String, withKey key: String) async throws -> URL {
    guard let url = try await KVdb.url(withKey: key, atBucket: bucketName) else {
      throw DemoError.noURLSetAt(bucketName, key)
    }
    return url
  }
  
  func getServerResponse(from url: URL, using session: URLSession = .shared, encoding: String.Encoding = .utf8) async throws -> String {
    let (data, _) = try await URLSession.shared.data(from: url)
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
        .task {
          
          let data : Data
          do {
            guard let url = try await KVdb.url(withKey: "hello", atBucket: "4WwQUN9AZrppSyLkbzidgo") else {
              return
            }
            (data, _) = try await URLSession.shared.data(from: url)
          } catch {
            return
          }
          guard let serverResponse = String(data: data, encoding: .utf8) else {
            return
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
