//
//  CustomTextField.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

class CustomTextField: UITextField {

    enum CustomTextFieldType {
        case username
        case email
        case password
    }
    
    private let authFieldType: CustomTextFieldType
    public let eyeButton = UIButton(type: .custom)
    
    init(fieldType: CustomTextFieldType) {
        self.authFieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        
        self.leftViewMode = .always
        self.rightViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .username:
            self.placeholder = "Username"
        case .email:
            self.placeholder = "Email Address"
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.placeholder = "Password"
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
            // "Eye" button
            eyeButton.setImage(UIImage(systemName: "eye.circle"), for: .normal)
            eyeButton.setImage(UIImage(systemName: "eye.slash.circle"), for: .selected)
            eyeButton.tintColor = .systemBlue
            eyeButton.translatesAutoresizingMaskIntoConstraints = false
            eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
            let eyeView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.size.height))
            

            
            eyeView.addSubview(eyeButton)
            self.rightView = eyeView
            
            NSLayoutConstraint.activate([
                eyeButton.centerXAnchor.constraint(equalTo: eyeView.centerXAnchor),
                eyeButton.centerYAnchor.constraint(equalTo: eyeView.centerYAnchor),
                eyeButton.widthAnchor.constraint(equalToConstant: 40),
                eyeButton.heightAnchor.constraint(equalTo: eyeView.heightAnchor),
                eyeView.widthAnchor.constraint(equalToConstant: 40)
            ])
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func togglePasswordVisibility() {
        self.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
}
