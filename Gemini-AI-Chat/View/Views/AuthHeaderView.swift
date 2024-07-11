//
//  AuthHeaderView.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

final class AuthHeaderView: UIView {
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logo")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.text = "Error"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "Error"
        return label
    }()

    init(title: String, subTitle: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.setupUI()
        self.applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyConstraints() {
        let logoImageViewConstraints = [
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 90),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
        ]
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 19),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]
        
        let subTitleLabelConstraints = [
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ]

        
        NSLayoutConstraint.activate(logoImageViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(subTitleLabelConstraints)
    }
}
