//
//  MenuViewController.swift
//  swift-login-system
//
//  Created by eren on 6.07.2024.
//

import UIKit

protocol MenuViewControllerDelegate: AnyObject {
    func didTabTitle(title: ChatTitle)
    func didTabDelete(title: ChatTitle)
}

class MenuViewController: UIViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    
    private var chatTitles = [ChatTitle]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        return tableView
    }()
    
    private let profilePicture: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "profilePicture")
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = "Loading..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        applyConstraints()
        
        ChatService.shared.fetchChatTitles { [weak self] chatTitles, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let chatTitles = chatTitles else {
                print("No chat titles found")
                return
            }
            
            self.chatTitles = chatTitles
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        AuthService.shared.fetchUser { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showFetchingUserError(on: self, with: error)
                return
            }
            
            if let user = user {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(user.username)"
                }
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(profilePicture)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
        
        title = "Messages"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            profilePicture.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            profilePicture.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            profilePicture.widthAnchor.constraint(equalToConstant: 40),
            profilePicture.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),  // Düzeltilmiş negatif constant
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: profilePicture.topAnchor, constant: -10),
        ])
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let text = chatTitles[indexPath.row].title
        
        cell.textLabel?.text = text
        cell.backgroundColor = .clear
        let bgColorView = UIView()
        bgColorView.backgroundColor = .secondarySystemGroupedBackground
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didTabTitle(title: chatTitles[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                let deleteAction = UIAction(title: "Delete", subtitle: nil, image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, state: .off) { [self] _ in
                    delegate?.didTabDelete(title: chatTitles[indexPath.row])
                    ChatService.shared.deleteTitle(chatId: chatTitles[indexPath.row].chatId)
                }
                deleteAction.attributes = .destructive
                
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [deleteAction])
            }
        return config
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
    }
    
}
