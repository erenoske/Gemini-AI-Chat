//
//  HomeViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "loading..."
        label.numberOfLines = 2
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.applyConstraints()
        
        self.label.text = "Erenoske\neren@gmail.com"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(didTabLogout))
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyConstraints() {
        let labelConstraints = [
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(labelConstraints)
    }
    
    @objc private func didTabLogout() {
        
    }

}
