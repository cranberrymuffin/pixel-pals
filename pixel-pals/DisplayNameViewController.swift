import UIKit

class DisplayNameViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var proceedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        proceedButton.isEnabled = false
        displayNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        // Enable button when there's input in the text field
        proceedButton.isEnabled = !displayNameTextField.text!.isEmpty
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        guard let displayName = displayNameTextField.text, !displayName.isEmpty else {
            return
        }
        
        // Initialize MultipeerManager with the custom display name
        MultipeerManager.initializeSharedInstance(with: displayName)
        // Transition to the home screen
        UIApplication.transitionToMainApp()
    }
}
