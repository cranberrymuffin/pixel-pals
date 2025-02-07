// HomeViewController.swift
import UIKit
import MultipeerConnectivity

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var peersTableView: UITableView!
    var isHost = true
    let multipeerManager = MultipeerManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
                
        peersTableView.delegate = self
        peersTableView.dataSource = self

        // Start Multipeer Connectivity
        multipeerManager?.onPeerUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.peersTableView.reloadData()
            }
        }
        
        multipeerManager?.onInvitationReceived = { [weak self] peerID, responseHandler in
            self?.showInvitationAlert(from: peerID, responseHandler: responseHandler)
        }
        
        multipeerManager?.start()
        NotificationCenter.default.addObserver(self, selector: #selector(peerConnected(_:)), name: .peerConnected, object: nil)

    }

    
    @objc func peerConnected(_ notification: Notification) {
        guard let peerID = notification.object as? MCPeerID else { return }
        DispatchQueue.main.async {
            
            // Once a peer is connected, show the calibration screen
            print("\(peerID.displayName) connected, transitioning to calibration screen.")
            
            // Transition to the calibration screen
            UIApplication.transitionToCalibrationScreen(isHost: self.isHost)
        }
    }
    @IBAction func signOut(_ sender: Any) {
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

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = multipeerManager?.foundPeers.count {
            return count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeerCell", for: indexPath) as! PeerCell
        if let multipeerManager = self.multipeerManager {
            let peer = multipeerManager.foundPeers[indexPath.row]
            cell.peerNameLabel.text = peer.displayName
            
            // Setup join button action for each cell
            cell.joinButtonAction = { [weak self] in
                multipeerManager.invitePeer(peer)
            }
        }

        
        return cell
    }
}
