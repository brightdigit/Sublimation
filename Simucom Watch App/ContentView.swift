//
//  ContentView.swift
//  Simucom Watch App
//
//  Created by Leo Dion on 10/31/22.
//

import SwiftUI

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
            (data, _) = try await URLSession.shared.data(from: URL(string: "http://127.0.0.1:8080")!)
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
