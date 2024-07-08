//
//  MenuView.swift
//  swift-login-system
//
//  Created by eren on 5.07.2024.
//

import UIKit

class MenuView: UIView {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        backgroundColor = .systemBackground
        
        AuthService.shared.fetchUser { [weak self] user, error in
            guard let self = self else { return }
            
            if let user = user {
                self.nameLabel.text = "\(user.username)\n\(user.email)"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
