//
//  ViewController.swift
//  vchat
//
//  Created by Aparna Natarajan on 2/3/25.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorDisplay: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AuthManager.shared.isLoggedIn() {
            UIApplication.transitionToMainApp()
        }
    }
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthManager.shared.loginUser(email: email, password: password, errorDisplay: errorDisplay)
    }
}

