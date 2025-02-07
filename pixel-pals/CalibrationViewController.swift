//
//  ClientCalibrationViewController.swift
//  vchat
//
//  Created by Aparna Natarajan on 2/5/25.
//

import UIKit

class CalibrationViewController: UIViewController {
    let multipeerManager = MultipeerManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Listen for disconnection events
        NotificationCenter.default.addObserver(self, selector: #selector(peerDisconnected(_:)), name: .peerDisconnected, object: nil)

    }
    
    
    @IBAction func disconnect(_ sender: Any) {
        multipeerManager?.disconnectFromAllPeers()
        multipeerManager?.start()
    }
    
    
    @objc func peerDisconnected(_ notification: Notification) {
        DispatchQueue.main.async {
            
            // Once a peer is connected, show the calibration screen
            self.multipeerManager?.start()
            // Transition to the calibration screen
            UIApplication.transitionToMainApp()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
