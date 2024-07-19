//
//  CustomButton.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

final class CustomButton: UIButton {

    enum FontSize {
        case big
        case med
        case small
    }
    
    enum ButtonType {
        case normal
        case google
    }
    
    init(title: String, hasBackground: Bool = false, fontSize: FontSize, type: ButtonType) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.backgroundColor = hasBackground ? .systemBackground : .clear
        
        let titleColor: UIColor = .label
        self.setTitleColor(titleColor, for: .normal)
        
        if hasBackground {
            self.layer.borderColor = UIColor.secondaryLabel.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 10
            self.layer.masksToBounds = true
        }
        
        switch type {
        case .google:
            var configuration = UIButton.Configuration.plain()
            if let originalImage = UIImage(named: "g-logo") {
                let resizedImage = originalImage.resized(to: CGSize(width: 50, height: 50))
                configuration.image = resizedImage
            }
            configuration.baseBackgroundColor = .systemBackground
            configuration.imagePadding = 10
            
            self.configuration = configuration
        case .normal:
            break
        }
        
        switch fontSize {
        case .big:
            self.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        case .med:
            self.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        case .small:
            self.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
