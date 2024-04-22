//
//  AdvertiserManager.swift
//  MultipeerDemo
//
//  Created by Leo on 2/27/24.
//

import Foundation
import MultipeerConnectivity
import Combine

struct Item : Codable, Identifiable {
    internal init(sourceID: Int, date: Date) {
        self.id = .init()
        self.sourceID = sourceID
        self.date = date
    }
    
    let sourceID : Int
    let date : Date
    let id : UUID
}

struct PeerAction {
    enum Action {
        case remove
        case add
    }
    let action: Action
    let peerID : Int
}
class AdvertiserManager : NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate,  MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session \(session.myPeerID) with \(peerID) chaged state to \(state)")
        
        guard let idString = peerID.displayName.components(separatedBy: .whitespaces).last else {
            return
        }
        
        guard let peerIDInt = Int(idString) else {
            return
        }
        
        let peerAction : PeerAction
        switch state {
        case .connected:
            peerAction = .init(action : .add, peerID : peerIDInt)
        case .notConnected:
            peerAction = .init(action: .remove, peerID : peerIDInt)
        default:
            return
        }
        
        self.peerActionSubject.send(peerAction)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("session \(session.myPeerID) with \(peerID) received \(data.count)")
        guard let item = try? jsonDecoder.decode(Item.self, from: data) else {
            return
        }
        self.itemsSubject.send(item)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("session \(session.myPeerID) with \(peerID) did receive stream \(streamName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
            print("session \(session.myPeerID) with \(peerID) did start receiving resource \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
            print("session \(session.myPeerID) with \(peerID) did start receive resource \(resourceName)")
    }
    
    let id : Int
    let advertiser : MCNearbyServiceAdvertiser
    let browser : MCNearbyServiceBrowser
    let session : MCSession
    
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    let peerActionSubject = PassthroughSubject<PeerAction, Never>()
    let itemsSubject = PassthroughSubject<Item, Never>()
    
    @Published var peers = Set<Int>()
    @Published var items = [Item]()
    
    var peersArray : [Int] {
        return .init(peers)
    }
    
    var cancellables = [AnyCancellable]()
    
    var peerID : MCPeerID {
        MCPeerID(displayName: "peer \(id)")
    }
    override init() {
        
        self.id = .random(in: 100...600)
        let peerID = MCPeerID(displayName: "peer \(id)")
        session = MCSession(peer: peerID)
        advertiser = .init(peer: peerID, discoveryInfo: nil, serviceType: "demo")
        browser = .init(peer: peerID, serviceType: "demo")
        super.init()
        advertiser.delegate = self
        browser.delegate = self
        session.delegate = self
        
        peerActionSubject.receive(on: DispatchQueue.main).sink { action in
            switch action.action {
            case .add:
                self.peers.formUnion([action.peerID])
            case .remove:
                self.peers.remove(action.peerID)
            }
        }.store(in: &self.cancellables)
        
        itemsSubject.receive(on: DispatchQueue.main).sink { item in
            
            self.items.insert(item, at: 0)
            
            let countToRemove = self.items.count - 5
            
            guard countToRemove > 0 else {
                return
            }
            self.items.removeLast(countToRemove)
        }.store(in: &self.cancellables)
            
    }
    
    func start () {
        Timer.publish(every: 1.0, on: .current, in: .common).autoconnect()
        .map {
            Item(sourceID: self.id, date: $0)
        }
        
        .encode(encoder: jsonEncoder)
        .assertNoFailure()
        .sink { data in
          guard !self.session.connectedPeers.isEmpty else {
            return
          }
            do {
                try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
                print("Sent data.")
            } catch {
                dump(error)
            }
        }.store(in: &self.cancellables)
        
        self.browser.startBrowsingForPeers()
        self.advertiser.startAdvertisingPeer()
        
        
    }
    
    func stop () {
        self.browser.stopBrowsingForPeers()
        self.advertiser.stopAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Advertiser did not strart \(advertiser.serviceType) error: \(error.localizedDescription)")
        dump(error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        session.connectPeer(peerID, withNearbyConnectionData: .init())
        invitationHandler(true, session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Browser \(browser.serviceType) lost \(peerID.displayName)")
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser did not strart \(browser.serviceType) error: \(error.localizedDescription)")
        dump(error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Browser \(browser.serviceType) found \(peerID.displayName)")
      browser.invitePeer(peerID, to: session, withContext: nil, timeout: 1.0)
//      session.nearbyConnectionData(forPeer: peerID) { data, error in
//        if let error = error {
//          print(error)
//        }
//      }
    }
}
