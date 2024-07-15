//
//  ModelChatTableViewCell.swift
//  swift-login-system
//
//  Created by eren on 12.07.2024.
//

import UIKit
import SwiftyMarkdown

final class ModelChatTableViewCell: UITableViewCell {
    
    static let identifier = "ModelChatTableViewCell"
    
    let textView = UITextView()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.tintColor = .label
        imageView.image = UIImage(named: "geminiLogo")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextView()
    }
    
    private func setupTextView() {
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link]
        contentView.addSubview(profileImageView)
        contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.widthAnchor.constraint(equalToConstant: 30),
            profileImageView.heightAnchor.constraint(equalToConstant: 30),
            
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    func configure(with text: String) {
        let markdownText = SwiftyMarkdown(string: text)
        let attributedText = markdownText.attributedString()
        textView.attributedText = attributedText
    }
}
