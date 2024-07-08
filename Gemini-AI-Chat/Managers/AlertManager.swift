//
//  AlertManager.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import Foundation
import UIKit

class AlertManager {
    
    private static func showBasicAlert(on vc: UIViewController, with title: String, and message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
    
}


// MARK: - Show Validation Alerts
extension AlertManager {
    
    public static func showInvalidEmailAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Invalid Email", and: "Please enter a valid email.")
    }
    
    public static func showInvalidPasswordAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Invalid Password", and: "Please enter a valid password.")
    }
    
    public static func showInvalidUsernameAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Invalid Username", and: "Please enter a valid username.")
    }
    
}

// MARK: - Registration Errors
extension AlertManager {
    
    public static func showRegistrationErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Unknown Registration Error", and: nil)
    }
    
    public static func showRegistrationErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, with: "Unknown Registration Error", and: "\(error.localizedDescription)")
    }
    
}

// MARK: - Log In Errors
extension AlertManager {
    
    public static func showSignInErrorAlert(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Unknown Error Signing In", and: nil)
    }
    
    public static func showSignInErrorAlert(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, with: "Unknown Sign In Error", and: "\(error.localizedDescription)")
    }
    
}

// MARK: - Log Out Errors
extension AlertManager {
    
    public static func showLogoutError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, with: "Log Out Error", and: "\(error.localizedDescription)")
    }
    
}

// MARK: - Forgot Password
extension AlertManager {
    
    public static func showPasswordResetSend(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Unkown Error Password Reset", and: nil)
    }
    
    public static func showErrorSendingPasswordReset(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, with: "Error Sending Password Reset", and: "\(error.localizedDescription)")
    }
    
}

// MARK: - Fetching User Errors
extension AlertManager {
    
    public static func showFetchingUserError(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Error Fetching User", and: nil)
    }
    
    public static func showFetchingUserError(on vc: UIViewController, with error: Error) {
        self.showBasicAlert(on: vc, with: "Unknown Error Fetching User", and: "\(error.localizedDescription)")
    }
    
}

// MARK: - Chat Errors

extension AlertManager {
    public static func showPhotoError(on vc: UIViewController) {
        self.showBasicAlert(on: vc, with: "Error", and: "Please enter a prompt before selecting image.")
    }
}
