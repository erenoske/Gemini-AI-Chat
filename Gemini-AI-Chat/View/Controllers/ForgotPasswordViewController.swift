//
//  ForgotPasswordViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

final class ForgotPasswordViewController: UIViewController {
    
    private let headerView = AuthHeaderView(title: "Forgot Password", subTitle: "Reset your password")
    private let emailField = CustomTextField(fieldType: .email)
    private let resetPasswordButton = CustomButton(title: "Sign Up", hasBackground: true, fontSize: .big, type: .normal)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.applyConstraints()
        self.resetPasswordButton.addTarget(self, action: #selector(didTabForgetPassword), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(resetPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        resetPasswordButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyConstraints() {
        
        let headerViewConstraints = [
            headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        let emailFieldConstraints = [
            emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 11),
            emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 40),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        let resetPasswordButtonConstraints = [
            resetPasswordButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            resetPasswordButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            resetPasswordButton.heightAnchor.constraint(equalToConstant: 40),
            resetPasswordButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        NSLayoutConstraint.activate(headerViewConstraints)
        NSLayoutConstraint.activate(emailFieldConstraints)
        NSLayoutConstraint.activate(resetPasswordButtonConstraints)
    }
    
    @objc private func didTabForgetPassword() {
        let email = self.emailField.text ?? ""
        
        if !Validator.isValidEmail(for: email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        AuthService.shared.forgotPassword(with: email) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showErrorSendingPasswordReset(on: self, with: error)
                return
            }
            
            AlertManager.showPasswordResetSend(on: self)
        }
    }
}
