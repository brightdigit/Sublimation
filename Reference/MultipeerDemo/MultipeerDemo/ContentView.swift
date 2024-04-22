//
//  ContentView.swift
//  MultipeerDemo
//
//  Created by Leo on 2/27/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    let dateFormatter : DateFormatter = {
        let formatter : DateFormatter = .init()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
    @StateObject var object = AdvertiserManager()
    var body: some View {
        Form{
            Section{
            HStack{
                Text("My ID:")
                Text(object.id.description)
            }
            }
            Section(header: Text("Connected To:")){
                
                ForEach(self.object.peersArray, id: \.self) { peer in
                    Text(peer.description)
                }
            }
            Section(header: Text("Last Messages")) {
                ForEach(self.object.items) { item in
                    HStack{
                        Text(dateFormatter.string(from: item.date))
                        Spacer()
                        Text(item.sourceID.description)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            self.object.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
