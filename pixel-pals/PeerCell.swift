// PeerCell.swift
import UIKit

class PeerCell: UITableViewCell {
    @IBOutlet weak var peerNameLabel: UILabel!
    
    var joinButtonAction: (() -> Void)?

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        joinButtonAction?()  // Call the closure to handle the action
    }
}
