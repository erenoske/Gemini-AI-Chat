//
//  HomeViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit
import SwiftyMarkdown
import PhotosUI

class HomeViewController: UIViewController {
    
    var titles = [ChatModel]()
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private var viewModel: ChatViewModel
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UserChatTableViewCell.self, forCellReuseIdentifier: UserChatTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        return tableView
    }()
    
    private lazy var placeHolder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 20
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.secondaryLabel.cgColor
        textView.backgroundColor = .systemBackground
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 10, bottom: 0, right: 10)
        return textView
    }()
    
    private lazy var sentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return button
    }()
    
    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return button
    }()
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        sentButton.addTarget(self, action: #selector(didTapSentButton), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(didTabSentPhoto), for: .touchUpInside)
        
        title = "Gemini"
        view.backgroundColor = .systemBackground

        setupUI()
        configureNavbar()
        applyConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    private func configureNavbar() {
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(didTabLogout))
        logoutButton.tintColor = .label
        navigationItem.rightBarButtonItem = logoutButton
        
        let burgerButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: nil, action: nil)
        burgerButton.tintColor = .label
        navigationItem.leftBarButtonItem = burgerButton
        
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        
        let standardNavAppearance = UINavigationBarAppearance()
        standardNavAppearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = standardNavAppearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(sentButton)
        view.addSubview(photoButton)
        textView.addSubview(placeHolder)
    }
    
    @objc func keyboardWillShow() {
        let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom)
        if bottomOffset.y > 0 {
            tableView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    private func adjustTextFieldHeight() {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = calculateTextViewHeight(from: newSize)
        textViewHeightConstraint.constant = newHeight
        view.layoutIfNeeded()
    }
    
    private func calculateTextViewHeight(from size: CGSize) -> CGFloat {
        let maxHeight: CGFloat = 150
        if size.height >= maxHeight {
            textView.isScrollEnabled = true
            return maxHeight
        } else {
            textView.isScrollEnabled = false
            return size.height + 10
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.scrollToRow()
        }
    }
    
    private func applyConstraints() {
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 40)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: photoButton.leadingAnchor, constant: 35),
            textView.trailingAnchor.constraint(equalTo: sentButton.trailingAnchor, constant: -30),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            textViewHeightConstraint,
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -10),
            
            placeHolder.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeHolder.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 15),
            placeHolder.widthAnchor.constraint(equalToConstant: 170),
            
            sentButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sentButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            photoButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            photoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalToConstant: 90)
            ])
    }
    
    @objc private func didTabLogout() {
        AuthService.shared.signOut { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showLogoutError(on: self, with: error)
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as?
                SceneDelegate {
                sceneDelegate.checkAuthentication()
            }
        }
    }
    
    private func scrollToRow() {
        let newIndexPath = IndexPath(row: titles.count - 1, section: 0)
        tableView.scrollToRow(at: newIndexPath, at: .top, animated: true)
    }
    
    @objc private func didTapSentButton() {
        guard let text = textView.text, !text.isEmpty else { return }
        textView.text = nil
        textView.resignFirstResponder()
        imageView.isHidden = true
        
        // recall function to update placeholder visibility
        textViewDidChange(textView)
        
        titles.append(ChatModel(role: "user", parts: text, image: nil))
        titles.append(ChatModel(role: "model", parts: "Yükleniyor...", image: nil))
        reloadData()
        
        if titles.count == 1 {
            viewModel.sendMessage(with: text, and: nil)
        } else {
            viewModel.sendMessage(with: text, and: titles)
        }
        
    }
    
    @objc func didTabSentPhoto() {
        guard let text = textView.text, !text.isEmpty else {
            AlertManager.showPhotoError(on: self)
            return
        }
        
        var pickerConfiguration = PHPickerConfiguration()
        pickerConfiguration.selectionLimit = 1
        pickerConfiguration.filter = .images
        let picker = PHPickerViewController(configuration: pickerConfiguration)
        picker.isEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = titles[indexPath.row]
        
        if model.role == "user" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserChatTableViewCell.identifier, for: indexPath) as? UserChatTableViewCell else { return UITableViewCell() }
            
            cell.configure(with: model.parts, and: model.image)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            let markdownText = SwiftyMarkdown(string: titles[indexPath.row].parts)
        
            cell.textLabel?.attributedText = markdownText.attributedString()
            cell.textLabel?.numberOfLines = 0
            
            return cell
        }


    }
    
}

extension HomeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeHolder.isHidden = !textView.text.isEmpty
        adjustTextFieldHeight()
        view.layoutIfNeeded()
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            didTapSentButton()
            return false
        }
        
        return true
    }
}

extension HomeViewController: ChatViewModelDelegate {
    func updateLastMessage(with message: String) {
        
        titles.removeLast()
        titles.append(ChatModel(role: "model", parts: message, image: nil))
        reloadData()
    }
    
}

// MARK: - PHPickerViewController
extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self else { return }
                
                guard let image = image, error == nil else {
                    print("Failed to get image.")
                    return
                }
                
                
                DispatchQueue.main.async {
                    guard let selectedImage = image as? UIImage else { return }
                    self.titles.append(ChatModel(role: "user", parts: self.textView.text, image: selectedImage))
                    self.titles.append(ChatModel(role: "model", parts: "Yükleniyor...", image: nil))
                    self.viewModel.sendMessage(with: self.textView.text, and: self.titles, image: selectedImage)
                    self.imageView.isHidden = true
                    self.textView.resignFirstResponder()
                    self.textView.text = nil
                    self.textViewDidChange(self.textView)
                }
            }
        }
    }
}
