import MultipeerConnectivity

class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    static var shared: MultipeerManager?  // The singleton is now optional

    var peerID: MCPeerID
    var session: MCSession
    var advertiser: MCNearbyServiceAdvertiser
    var browser: MCNearbyServiceBrowser

    var foundPeers: [MCPeerID] = []
    var onPeerUpdate: (() -> Void)? // Callback to update UI when peers change
    var onInvitationReceived: ((MCPeerID, @escaping (Bool) -> Void) -> Void)?

    // Updated initializer to accept a custom display name
    init(displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "vchat")
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "vchat")
        
        super.init()
        
        self.session.delegate = self
        self.advertiser.delegate = self
        self.browser.delegate = self
    }

    // A static method to initialize the shared instance
    static func initializeSharedInstance(with displayName: String) {
        shared = MultipeerManager(displayName: displayName)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
            switch state {
            case .connected:
                print("\(peerID.displayName) connected.")
                // Notify HomeViewController that the peer is connected
                NotificationCenter.default.post(name: .peerConnected, object: peerID)
            case .connecting:
                print("\(peerID.displayName) is connecting...")
            case .notConnected:
                print("\(peerID.displayName) disconnected.")
            @unknown default:
                print("Unknown state for \(peerID.displayName).")
            }
        }
    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        print("Started advertising and browsing.")
    }
    
    func stop() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        print("Stopped advertising and browsing.")
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // This is the sendData method to send data to peers
    func sendData(_ message: String) {
        guard !session.connectedPeers.isEmpty else {
            print("No connected peers to send data.")
            return
        }
        
        do {
            let data = message.data(using: .utf8)!
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
    
    // Disconnect from all peers by closing the session
    func disconnectFromAllPeers() {
        // Close the session to disconnect from all peers
        session.disconnect()
        print("Disconnected from all peers.")
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        onInvitationReceived?(peerID) { accepted in
            invitationHandler(accepted, self.session)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertising: \(error.localizedDescription)")
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if !foundPeers.contains(peerID) {
            foundPeers.append(peerID)
            onPeerUpdate?()
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.firstIndex(of: peerID) {
            foundPeers.remove(at: index)
            onPeerUpdate?()
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
}
