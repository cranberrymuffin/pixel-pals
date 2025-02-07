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
    }
    
    
    @IBAction func disconnect(_ sender: Any) {
        multipeerManager?.start()
        UIApplication.transitionToMainApp()
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
