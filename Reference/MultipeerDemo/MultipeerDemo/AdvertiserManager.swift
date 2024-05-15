//
//  AdvertiserManager.swift
//  Sublimation
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Combine
import Foundation
import MultipeerConnectivity

struct Item: Codable, Identifiable {
  internal init(sourceID: Int, date: Date) {
    id = .init()
    self.sourceID = sourceID
    self.date = date
  }

  let sourceID: Int
  let date: Date
  let id: UUID
}

struct PeerAction {
  enum Action {
    case remove
    case add
  }

  let action: Action
  let peerID: Int
}

class AdvertiserManager: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    print("session \(session.myPeerID) with \(peerID) chaged state to \(state)")

    guard let idString = peerID.displayName.components(separatedBy: .whitespaces).last else {
      return
    }

    guard let peerIDInt = Int(idString) else {
      return
    }

    let peerAction: PeerAction
    switch state {
    case .connected:
      peerAction = .init(action: .add, peerID: peerIDInt)
    case .notConnected:
      peerAction = .init(action: .remove, peerID: peerIDInt)
    default:
      return
    }

    peerActionSubject.send(peerAction)
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    print("session \(session.myPeerID) with \(peerID) received \(data.count)")
    guard let item = try? jsonDecoder.decode(Item.self, from: data) else {
      return
    }
    itemsSubject.send(item)
  }

  func session(_ session: MCSession, didReceive _: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    print("session \(session.myPeerID) with \(peerID) did receive stream \(streamName)")
  }

  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with _: Progress) {
    print("session \(session.myPeerID) with \(peerID) did start receiving resource \(resourceName)")
  }

  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at _: URL?, withError _: Error?) {
    print("session \(session.myPeerID) with \(peerID) did start receive resource \(resourceName)")
  }

  let id: Int
  let advertiser: MCNearbyServiceAdvertiser
  let browser: MCNearbyServiceBrowser
  let session: MCSession

  let jsonEncoder = JSONEncoder()
  let jsonDecoder = JSONDecoder()

  let peerActionSubject = PassthroughSubject<PeerAction, Never>()
  let itemsSubject = PassthroughSubject<Item, Never>()

  @Published var peers = Set<Int>()
  @Published var items = [Item]()

  var peersArray: [Int] {
    .init(peers)
  }

  var cancellables = [AnyCancellable]()

  var peerID: MCPeerID {
    MCPeerID(displayName: "peer \(id)")
  }

  override init() {
    id = .random(in: 100 ... 600)
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
    }.store(in: &cancellables)

    itemsSubject.receive(on: DispatchQueue.main).sink { item in

      self.items.insert(item, at: 0)

      let countToRemove = self.items.count - 5

      guard countToRemove > 0 else {
        return
      }
      self.items.removeLast(countToRemove)
    }.store(in: &cancellables)
  }

  func start() {
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
      }.store(in: &cancellables)

    browser.startBrowsingForPeers()
    advertiser.startAdvertisingPeer()
  }

  func stop() {
    browser.stopBrowsingForPeers()
    advertiser.stopAdvertisingPeer()
  }

  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    print("Advertiser did not strart \(advertiser.serviceType) error: \(error.localizedDescription)")
    dump(error)
  }

  func advertiser(_: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext _: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
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

  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo _: [String: String]?) {
    print("Browser \(browser.serviceType) found \(peerID.displayName)")
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 1.0)
//      session.nearbyConnectionData(forPeer: peerID) { data, error in
//        if let error = error {
//          print(error)
//        }
//      }
  }
}
