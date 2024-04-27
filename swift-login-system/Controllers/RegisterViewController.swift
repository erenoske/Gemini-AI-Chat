//
//  RegisterViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let headerView = AuthHeaderView(title: "Sign Up", subTitle: "Create your account")
    private let usernameField = CustomTextField(fieldType: .username)
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signUpButton = CustomButton(title: "Sign Up", hasBackground: true, fontSize: .big)
    private let signInButton = CustomButton(title: "Already have an account? Sign In.", fontSize: .med)
    
    private let termsTextView: UITextView = {

        let attributedString = NSMutableAttributedString(string: "By creating an account, you agree to our Terms & Conditions and you ackowledge that you have read our Privacy Policy.")
        attributedString.addAttribute(.link, value: "terms://termsAndConditions", range: (attributedString.string as NSString).range(of: "Terms & Conditions"))
        attributedString.addAttribute(.link, value: "privacy://privacyPolicy", range: (attributedString.string as NSString).range(of: "Privacy Policy"))
        
        let tv = UITextView()
        tv.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        tv.backgroundColor = .clear
        tv.attributedText = attributedString
        tv.textColor = .label
        tv.isSelectable = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        self.setupUI()
        self.applyConstraints()
        
        self.usernameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        
        self.termsTextView.delegate = self
        
        self.signUpButton.addTarget(self, action: #selector(didTabSignUp), for: .touchUpInside)
        self.signInButton.addTarget(self, action: #selector(didTabSignIn), for: .touchUpInside)
    }
    
    @objc private func didTabSignUp() {
        
        let registerUserRequest = RegisterUserRequest(
            username: self.usernameField.text ?? "",
            email: self.emailField.text ?? "",
            password: self.passwordField.text ?? ""
        )
        
        // Username check
        if !Validator.isValidUsername(for: registerUserRequest.username) {
            AlertManager.showInvalidUsernameAlert(on: self)
            return
        }
        
        // Email check
        if !Validator.isValidEmail(for: registerUserRequest.email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        // Password check
        if !Validator.isPasswordValid(for: registerUserRequest.password) {
            AlertManager.showInvalidPasswordAlert(on: self)
            return
        }
        
        let overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(overlayView)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        overlayView.addSubview(activityIndicator)
        activityIndicator.center = overlayView.center
        
        AuthService.shared.registerUser(with: registerUserRequest) { [weak self] wasRegistered, error in
            
            overlayView.removeFromSuperview()
            
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showRegistrationErrorAlert(on: self, with: error)
                return
            }
            
            if wasRegistered {
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.checkAuthentication()
                }
            } else {
                AlertManager.showRegistrationErrorAlert(on: self)
            }
        }
    }
    
    @objc private func didTabSignIn() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsTextView)
        view.addSubview(signInButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false

    }
    
    private func applyConstraints() {
        let headerViewConstraints = [
            headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        let usernameFieldConstraints = [
            usernameField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            usernameField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            usernameField.heightAnchor.constraint(equalToConstant: 40),
            usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        let emailFieldConstraints = [
            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 22),
            emailField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 40),
            emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]

        
        let passwordFieldConstraints = [
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            passwordField.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 40),
            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        let signUpButtonConstraints = [
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            signUpButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        let termsTextViewConstraints = [
            termsTextView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 11),
            termsTextView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            termsTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        
        let signInButtonConstraints = [
            signInButton.topAnchor.constraint(equalTo: termsTextView.bottomAnchor, constant: 22),
            signInButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95)
        ]
        

        
        NSLayoutConstraint.activate(headerViewConstraints)
        NSLayoutConstraint.activate(usernameFieldConstraints)
        NSLayoutConstraint.activate(emailFieldConstraints)
        NSLayoutConstraint.activate(passwordFieldConstraints)
        NSLayoutConstraint.activate(signUpButtonConstraints)
        NSLayoutConstraint.activate(termsTextViewConstraints)
        NSLayoutConstraint.activate(signInButtonConstraints)
    }
}


extension RegisterViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if URL.scheme == "terms" {
            self.showWebViewerController(with: "https://policies.google.com/terms?hl=en")
        } else if URL.scheme == "privacy" {
            self.showWebViewerController(with: "https://policies.google.com/privacy?hl=en")
        }
        
        return false
    }
    
    private func showWebViewerController(with urlString: String) {
        let vc = WebViewController(with: urlString)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = .white
        self.present(nav, animated: true, completion: nil)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.delegate = nil
        textView.selectedTextRange = nil
        textView.delegate = self
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            didTabSignUp()
        }
        
        return true
    }
}
