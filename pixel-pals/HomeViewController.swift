import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    

    @IBOutlet weak var peersTableView: UITableView!
    
    var isHost = true
    var foundPeers: [MCPeerID] = [] // List of found peers
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    let multipeerManager = MultipeerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peersTableView.delegate = self
        peersTableView.dataSource = self
        
        // Set up the advertiser and browser
        setUpPeerServices()
        
        multipeerManager?.onPeerUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.peersTableView.reloadData()  // Refresh the table view when peers are updated
            }
        }
        
        multipeerManager?.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(peerConnected(_:)), name: .peerConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }

    func setUpPeerServices() {
        // Initialize the browser and advertiser with the current peerID
        guard let peerID = multipeerManager?.peerID else { return }

        // Set up the advertiser and browser
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "vchat")
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "vchat")
        
        browser.delegate = self
        advertiser.delegate = self
        
        browser.startBrowsingForPeers()
        advertiser.startAdvertisingPeer()
        
        print("Started advertising and browsing.")
    }

    // When the app is about to close or go to the background
    @objc func appWillEnterBackground() {
        // Disconnect from all peers
        multipeerManager?.disconnectFromAllPeers()
    }

    deinit {
        // Remove observer to prevent memory leaks
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .peerConnected, object: nil)
    }

    @objc func peerConnected(_ notification: Notification) {
        guard let peerID = notification.object as? MCPeerID else { return }
        DispatchQueue.main.async {
            // Once a peer is connected, show the calibration screen
            print("\(peerID.displayName) connected, transitioning to calibration screen.")
            self.multipeerManager?.stop()
            // Transition to the calibration screen
            UIApplication.transitionToCalibrationScreen(isHost: self.isHost)
        }
    }

    func showInvitationAlert(from peerID: MCPeerID, responseHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Incoming Connection", message: "\(peerID.displayName) wants to connect.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
            responseHandler(true)
            self.isHost = false
        })
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel) { _ in
            responseHandler(false)
        })
        self.present(alert, animated: true)
    }

    @IBAction func signOut(_ sender: Any) {
        // Stop the Multipeer session and disconnect
        multipeerManager?.stop()
        multipeerManager?.disconnectFromAllPeers()
        
        // Transition back to the DisplayName screen
        UIApplication.transitionToDisplayNameScreen()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of found peers
        return foundPeers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath) as! PeerCell

        let peer = self.foundPeers[indexPath.row]
        cell.peerNameLabel.text = peer.displayName

        // Setup join button action for each cell
        cell.joinButtonAction = { [weak self] in
            guard let self = self else { return }
            // Directly invite the peer from HomeViewController
            self.invitePeer(peer)
        }
    

        return cell
    }

    func invitePeer(_ peerID: MCPeerID) {
        // Use the browser to invite the peer to join the session
        if let session = multipeerManager?.session {
            self.browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
        print("Invitation sent to \(peerID.displayName)")
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !foundPeers.contains(peerID) {
            foundPeers.append(peerID)
            multipeerManager?.onPeerUpdate?() // Notify UI to refresh
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.firstIndex(of: peerID) {
            foundPeers.remove(at: index)
            multipeerManager?.onPeerUpdate?() // Notify UI to refresh
        }
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Error starting advertising: \(error.localizedDescription)")
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Show a prompt or alert to the user, asking whether to accept or decline the invitation
        let alert = UIAlertController(title: "Incoming Invitation", message: "\(peerID.displayName) wants to connect.", preferredStyle: .alert)

        // Accept the invitation
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
            // When the user accepts the invitation, create a new session or continue with the existing session
            invitationHandler(true, self.multipeerManager?.session)
            
            // Optionally, perform additional setup or navigation if the invitation is accepted
            self.isHost = false // Set to false, since the current user is not the host anymore
            print("\(peerID.displayName) invited and accepted.")
        }))

        // Decline the invitation
        alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
            print("Invitation from \(peerID.displayName) declined.")
        }))
        
        // Present the alert to the user
        self.present(alert, animated: true, completion: nil)
    }

}
