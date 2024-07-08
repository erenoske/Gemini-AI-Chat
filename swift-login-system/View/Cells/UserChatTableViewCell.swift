//
//  UserChatTableViewCell.swift
//  swift-login-system
//
//  Created by eren on 2.07.2024.
//

import UIKit

class UserChatTableViewCell: UITableViewCell {

    static let identifier = "UserChatTableViewCell"
    
    private lazy var messageBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()
    
    public lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let photoView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private var contentImageViewHeightConstraint: NSLayoutConstraint!
    private var contentImageViewWidthConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureView() {
        selectionStyle = .none
        contentView.addSubview(messageBackgroundView)
        contentView.addSubview(photoView)
        messageBackgroundView.addSubview(messageLabel)
    }
    
    private func configureConstraints() {
        contentImageViewHeightConstraint = photoView.heightAnchor.constraint(equalToConstant: 200)
        contentImageViewWidthConstraint = photoView.widthAnchor.constraint(equalToConstant: 300)
        
        
        NSLayoutConstraint.activate([
            messageBackgroundView.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 10),
            messageBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 48),
            messageBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            messageBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -10),
            
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentImageViewWidthConstraint,
            contentImageViewHeightConstraint,
        ])
    }
    
    public func configure(with text: String, and image: UIImage?) {
        messageLabel.text = text
        
        if let image = image {
            photoView.image = image
            photoView.isHidden = false
            
            var width = Double()
            
            if image.size.height > image.size.width {
                width = 150.0
            } else {
                width = 300.0
            }
            
            let aspectRatio = image.size.height / image.size.width
            let newHeight = width * aspectRatio
            contentImageViewHeightConstraint.constant = newHeight
            contentImageViewWidthConstraint.constant = width
            
        } else {
            photoView.isHidden = true
            contentImageViewHeightConstraint.constant = 0
        }
    }
}
