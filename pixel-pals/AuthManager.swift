import UIKit
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            } catch let err {
                print(err)
            }
    }
    
    func isLoggedIn()-> Bool {
        return Auth.auth().currentUser != nil && Auth.auth().currentUser?.isEmailVerified == true
    }
    
    func loggedInUser()-> String? {
        return Auth.auth().currentUser?.email
    }
    
    func signUpUser(email: String, password: String, infoLabel: UILabel) -> String{
        var ret = ""
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                ret = error.localizedDescription
                self.showError(ret, errorDisplay: infoLabel)
                return
            }
            
            guard let user = authResult?.user else {
                ret = ("❌ No user object found after sign-up.")
                self.showError(ret, errorDisplay: infoLabel)

                return
            }
            user.sendEmailVerification { error in
                if let error = error {
                    ret = (error.localizedDescription)
                    self.showError(ret, errorDisplay: infoLabel)

                } else {
                    ret = ("✅ Verification email sent.")
                    self.showError(ret, errorDisplay: infoLabel)
                }
            }
        }
        print(ret)
        return ret
    }
    func showError(_ message: String, errorDisplay: UILabel) {
        errorDisplay.text = message
        errorDisplay.isHidden = false
    }
    // Login
    func loginUser(email: String, password: String, errorDisplay: UILabel) {
        var ret = ""
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                ret = error.localizedDescription
                self.showError(ret, errorDisplay: errorDisplay)

                return
            }
            
            guard let user = Auth.auth().currentUser else {
                ret = ("❌ No authenticated user found.")
                self.showError(ret, errorDisplay: errorDisplay)

                return
            }
            
            if user.isEmailVerified {
                ret = "✅ Email verified, proceeding to Home screen"
                print(ret)

                UIApplication.transitionToMainApp()
            } else {
                ret = "⚠️ Email not verified. Please check your inbox."
                self.showError(ret, errorDisplay: errorDisplay)

                self.resendVerificationEmail()
            }
        }
    }
    
    // Resend Verification Email
       func resendVerificationEmail() {
           guard let user = Auth.auth().currentUser else {
               print("❌ No user found to resend verification email.")
               return
           }
           
           user.sendEmailVerification { error in
               if let error = error {
                   print("❌ Error resending verification email: \(error.localizedDescription)")
               } else {
                   print("✅ Verification email re-sent. Check your inbox.")
               }
           }
       }
    
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("❌ Error sending password reset email: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                print("✅ Password reset email sent successfully.")
                completion(true, nil)
            }
        }
    }
}
