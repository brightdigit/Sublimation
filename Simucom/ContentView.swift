//
//  ContentView.swift
//  Simucom
//
//  Created by Leo Dion on 10/31/22.
//

import SwiftUI
import Sublimation

struct ContentView: View {
  @State var serverResponse : String = ""
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
