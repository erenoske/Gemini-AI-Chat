//
//  LoginViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

final class LoginViewController: UIViewController {
    
    private let headerView = AuthHeaderView(title: "Sign In", subTitle: "Sign in to your account")
    private let emailField = CustomTextField(fieldType: .email)
    private let passwordField = CustomTextField(fieldType: .password)
    
    private let signInButton = CustomButton(title: "Sign In", hasBackground: true, fontSize: .big)
    private let newUserButton = CustomButton(title: "New User? Create Account.", fontSize: .med)
    private let forgotPasswordButton = CustomButton(title: "Forgot Password?", fontSize: .small)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.emailField.delegate = self
        self.passwordField.delegate = self

        self.setupUI()
        self.applyConstraints()
        
        self.signInButton.addTarget(self, action: #selector(didTabSignIn), for: .touchUpInside)
        self.newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    @objc private func didTabSignIn() {
        view.endEditing(true)
        
        let loginRequest = LoginUserRequest(
            email: self.emailField.text ?? "",
            password: self.passwordField.text ?? ""
        )
        
        // Email check
        if !Validator.isValidEmail(for: loginRequest.email) {
            AlertManager.showInvalidEmailAlert(on: self)
            return
        }
        
        // Password check
        if !Validator.isPasswordValid(for: loginRequest.password) {
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
        
        AuthService.shared.signIn(with: loginRequest) { [weak self] error in
            overlayView.removeFromSuperview()
            
            guard let self = self else {return}
            
            if let error = error {
                AlertManager.showSignInErrorAlert(on: self, with: error)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
        }
    }


    
    @objc private func didTapNewUser() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(emailField)
        contentView.addSubview(passwordField)
        contentView.addSubview(signInButton)
        contentView.addSubview(newUserButton)
        contentView.addSubview(forgotPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        newUserButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyConstraints() {

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let headerViewConstraints = [
            headerView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        let emailFieldConstraints = [
            emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5),
            emailField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 40),
            emailField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            emailField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ]
        
        let passwordFieldConstraints = [
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 22),
            passwordField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 40),
            passwordField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            passwordField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ]
        
        let signInButtonConstraints = [
            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            signInButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            signInButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ]
        
        let newUserButtonConstraints = [
            newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor),
            newUserButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            newUserButton.heightAnchor.constraint(equalToConstant: 50),
            newUserButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            newUserButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ]
        
        let forgotPasswordButtonConstraints = [
            forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            forgotPasswordButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Alt kısıt ekleyin
        ]
        
        NSLayoutConstraint.activate(headerViewConstraints)
        NSLayoutConstraint.activate(emailFieldConstraints)
        NSLayoutConstraint.activate(passwordFieldConstraints)
        NSLayoutConstraint.activate(signInButtonConstraints)
        NSLayoutConstraint.activate(newUserButtonConstraints)
        NSLayoutConstraint.activate(forgotPasswordButtonConstraints)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            didTabSignIn()
        }
        
        return true
    }
}
