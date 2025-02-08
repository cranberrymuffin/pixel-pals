import MultipeerConnectivity

class MultipeerManager: NSObject, MCSessionDelegate {

    static var shared: MultipeerManager?

    var peerID: MCPeerID
    var session: MCSession
    var onPeerUpdate: (() -> Void)? // Callback to update UI when peers change

    init(displayName: String) {
        self.peerID = MCPeerID(displayName: displayName)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()

        self.session.delegate = self
    }

    static func initializeSharedInstance(with displayName: String) {
        shared = MultipeerManager(displayName: displayName)
    }

    func start() {
        // Start session here if needed
        print("Multipeer Manager started.")
    }

    func stop() {
        // Stop session here if needed
        print("Multipeer Manager stopped.")
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        // Invite peer logic
    }

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
    
    func disconnectFromAllPeers() {
        session.disconnect()
        print("Disconnected from all peers.")
    }

    // MARK: - MCSessionDelegate Methods
    
    // Required methods for MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) connected.")
            // Notify HomeViewController that the peer is connected
            NotificationCenter.default.post(name: .peerConnected, object: peerID)
        case .connecting:
            print("\(peerID.displayName) is connecting...")
        case .notConnected:
            NotificationCenter.default.post(name: .peerDisconnected, object: peerID)
        @unknown default:
            print("Unknown state for \(peerID.displayName).")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle receiving data from peer
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle receiving resource (if any)
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle finished receiving resource (if any)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle receiving stream (if any)
    }
}
