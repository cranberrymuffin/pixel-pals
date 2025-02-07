//
//  UIHelpers.swift
//  vchat
//
//  Created by Aparna Natarajan on 2/3/25.
//

import UIKit

extension UIApplication {
    static func goBack(view: UIViewController) {
        view.navigationController?.popToRootViewController(animated: false)
    }
    static func displayView(mainVC: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("❌ Failed to get window")
            return
        }
        
        let newNavController = UINavigationController(rootViewController: mainVC)

        // Replace rootViewController and make the window visible
        window.rootViewController = newNavController
        window.makeKeyAndVisible()

        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    static func transitionToCalibrationScreen(isHost: Bool) {

        // Load the MainViewController from Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVc = if isHost {
            storyboard.instantiateViewController(withIdentifier: "HostCalibrationViewController") as? CalibrationViewController
        } else {
            storyboard.instantiateViewController(withIdentifier: "ClientCalibrationViewController") as? CalibrationViewController
        }
        if let mainVc = mainVc {
            displayView(mainVC: mainVc)
        }
    }
    static func transitionToMainApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("❌ Failed to get window")
            return
        }

        // Load the MainViewController from Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            displayView(mainVC: mainVC)
        } else {
            print("❌ Failed to instantiate HomeViewController from Storyboard")
        }
    }
    
    static func transitionToLogin() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            print("❌ Failed to get window")
            return
        }

        // Load the MainViewController from Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            displayView(mainVC: mainVC)
        } else {
            print("❌ Failed to instantiate LoginViewController from Storyboard")
        }
    }
}
