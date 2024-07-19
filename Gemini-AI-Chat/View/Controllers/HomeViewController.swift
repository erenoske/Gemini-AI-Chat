//
//  HomeViewController.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit
import PhotosUI
import SideMenu

final class HomeViewController: UIViewController {
    
    public var titles = [ChatModel]() {
        didSet {
            DispatchQueue.main.async {
                self.imageView.isHidden = true
            }
        }
    }
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    private var buttonsStackViewConstraint: NSLayoutConstraint!
    
    private var viewModel: ChatViewModel
    
    private var viewController: MenuViewController

    private var id = UUID().uuidString
    
    private var loading = false {
        didSet {
            updateLoadingState()
        }
    }

    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logo")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = false
        tableView.register(ModelChatTableViewCell.self, forCellReuseIdentifier: ModelChatTableViewCell.identifier)
        tableView.register(UserChatTableViewCell.self, forCellReuseIdentifier: UserChatTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
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
        textView.layer.borderColor = UIColor.darkGray.cgColor
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
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [photoButton, cameraButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 15
        return stackView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(viewModel: ChatViewModel, viewController: MenuViewController) {
        self.viewModel = viewModel
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
        viewController.delegate = self
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
        cameraButton.addTarget(self, action: #selector(didTabCameraButton), for: .touchUpInside)
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        configureSideMenu()
        configureNavbar()
        applyConstraints()

    }
    
    
    private func configureNavbar() {
        title = "Gemini"
        
        let logoutButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(didTabNewChat))
        logoutButton.tintColor = .label
        navigationItem.rightBarButtonItem = logoutButton
        
        let burgerButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(didTabMenuBar))
        burgerButton.tintColor = .label
        navigationItem.leftBarButtonItem = burgerButton
        
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        
        let standardNavAppearance = UINavigationBarAppearance()
        standardNavAppearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = standardNavAppearance
    }
    
    private func configureSideMenu() {
        let menu = SideMenuNavigationController(rootViewController: viewController)
        menu.leftSide = true
        menu.menuWidth = 300
        menu.presentationStyle = .viewSlideOutMenuIn
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(sentButton)
        view.addSubview(buttonsStackView)
        view.addSubview(activityIndicator)
        textView.addSubview(placeHolder)
    }
    
    func updateLoadingState() {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
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
    
    private func reloadChatData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.scrollToChatRow()
        }
    }
    
    private func scrollToChatRow() {
        let newIndexPath = IndexPath(row: titles.count - 1, section: 0)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: false)
    }
    
    private func applyConstraints() {
        textViewHeightConstraint = textView.heightAnchor.constraint(equalToConstant: 40)
        buttonsStackViewConstraint = buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: buttonsStackView.trailingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: sentButton.leadingAnchor, constant: -15),
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
            sentButton.widthAnchor.constraint(equalToConstant: 25),
            
            buttonsStackView.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            buttonsStackViewConstraint,
            buttonsStackView.widthAnchor.constraint(equalToConstant: 65),
            
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalToConstant: 90),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    private func scrollToRow() {
        let newIndexPath = IndexPath(row: titles.count - 1, section: 0)
        tableView.scrollToRow(at: newIndexPath, at: .top, animated: true)
    }
    
    private func getMessage(at index: Int) -> String {
        return titles[index].parts
    }

    private func removeMarkdownFormatting(from text: String) -> String {
        var cleanedText = text
        
        cleanedText = cleanedText.replacingOccurrences(of: #"(\*{1,2}|_{1,2}|`{1,2}|~{1,2})"#, with: "", options: .regularExpression)
        
        cleanedText = cleanedText.replacingOccurrences(of: #"!\?$begin:math:display$.*?$end:math:display$$begin:math:text$.*?$end:math:text$"#, with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: #"$begin:math:display$.*?$end:math:display$$begin:math:text$.*?$end:math:text$"#, with: "", options: .regularExpression)
        
        return cleanedText
    }
}

// MARK: - Action
extension HomeViewController {
    
    @objc func keyboardWillShow() {
        let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom)
        if bottomOffset.y > 0 {
            tableView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    @objc private func didTabNewChat() {
        if !loading {
            titles.removeAll()
            tableView.reloadData()
            id = UUID().uuidString
            viewModel.firstMessage = true
            DispatchQueue.main.async {
                self.imageView.isHidden = false
            }
        }
    }
    
    @objc private func didTapSentButton() {
        guard let text = textView.text, !text.isEmpty else { return }
        textView.text = nil
        textView.resignFirstResponder()
        
        // recall function to update placeholder visibility
        textViewDidChange(textView)
        
        if titles.count == 0 {
            viewModel.sendMessage(with: text, and: nil, id: id)
        } else {
            viewModel.sendMessage(with: text, and: titles, id: id)
        }
        
        titles.append(ChatModel(role: "user", parts: text, image: nil))
        titles.append(ChatModel(role: "model", parts: "Loading...", image: nil))
        reloadData()
        
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
    
    @objc func didTabCameraButton() {
        guard let text = textView.text, !text.isEmpty else {
            AlertManager.showPhotoError(on: self)
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func didTabMenuBar() {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
}

// MARK: - UITableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = titles[indexPath.row]
        
        if model.role == "user" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserChatTableViewCell.identifier, for: indexPath) as? UserChatTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model.parts, and: model.image)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ModelChatTableViewCell.identifier, for: indexPath) as? ModelChatTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: model.parts)
            
            return cell
        }
        


    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let selectedMessage = getMessage(at: indexPath.row)
        let cleanSelectedMessage = removeMarkdownFormatting(from: selectedMessage)
        
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { _ in
                let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                    UIPasteboard.general.string = cleanSelectedMessage
                }
                
                let showTextAction = UIAction(title: "Select Text", image: UIImage(systemName: "text.viewfinder")) { _ in
                    let textDisplayVC = TextDisplayViewController(text: cleanSelectedMessage)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let sceneDelegate = windowScene.delegate as? SceneDelegate,
                       let rootViewController = sceneDelegate.window?.rootViewController {
                        
                        rootViewController.present(textDisplayVC, animated: true, completion: nil)
                    }
                }
                
                let shareTextAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    let activityViewController = UIActivityViewController(activityItems: [cleanSelectedMessage], applicationActivities: nil)

                    activityViewController.popoverPresentationController?.sourceView = self.view
                    
                    self.present(activityViewController, animated: true, completion: nil)
                }
                
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [copyAction, showTextAction, shareTextAction])
            }
        
        return config
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
    }
}

// MARK: - UITextView
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

// MARK: - ChatViewModelDelegate
extension HomeViewController: ChatViewModelDelegate {
    func updateLastMessage(with message: String) {
        
        if titles.count > 0 {
            titles.removeLast()
        }
        
        titles.append(ChatModel(role: "model", parts: message, image: nil))
        reloadData()
        
        HapticsManager.shared.vibrate()
    }
    
}

// MARK: - MenuViewControllerDelegate
extension HomeViewController: MenuViewControllerDelegate {
    
    func didTabDelete(title: ChatTitle) {
        if id == title.chatId {
            id = UUID().uuidString
            titles.removeAll()
            viewModel.firstMessage = true
            tableView.reloadData()
            SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async {
                self.imageView.isHidden = false
            }
        }
    }
    
    func didTabTitle(title: ChatTitle) {
        loading = true
        id = title.chatId
        titles.removeAll()
        tableView.reloadData()
        viewModel.firstMessage = false
        imageView.isHidden = true
        SideMenuManager.default.leftMenuNavigationController?.dismiss(animated: true, completion: nil)
        ChatService.shared.fetchChat(chatId: title.chatId) { data, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let data = data {
                self.titles = data
                DispatchQueue.main.async {
                    self.reloadChatData()
                    self.loading = false
                }
            }
        }
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
                
                guard let selectedImage = image as? UIImage else { return }
                
                
                DispatchQueue.main.async {
                    if self.titles.count == 0 {
                        self.viewModel.sendMessage(with: self.textView.text, and: nil, id: self.id, image: selectedImage)
                    } else {
                        self.viewModel.sendMessage(with: self.textView.text, and: self.titles, id: self.id, image: selectedImage)
                    }
                }
                
                DispatchQueue.main.async {
                    self.titles.append(ChatModel(role: "user", parts: self.textView.text, image: selectedImage))
                    self.titles.append(ChatModel(role: "model", parts: "Loading...", image: nil))
                    self.imageView.isHidden = true
                    self.textView.resignFirstResponder()
                    self.textView.text = nil
                    self.textViewDidChange(self.textView)
                    self.reloadData()
                }
            }
        }
    }
}

// MARK: - UIImagePickerController
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        
        DispatchQueue.main.async {
            if self.titles.count == 0 {
                self.viewModel.sendMessage(with: self.textView.text, and: nil, id: self.id, image: selectedImage)
            } else {
                self.viewModel.sendMessage(with: self.textView.text, and: self.titles, id: self.id, image: selectedImage)
            }
        }
        
        DispatchQueue.main.async {
            self.titles.append(ChatModel(role: "user", parts: self.textView.text, image: selectedImage))
            self.titles.append(ChatModel(role: "model", parts: "Loading...", image: nil))
            self.imageView.isHidden = true
            self.textView.resignFirstResponder()
            self.textView.text = nil
            self.textViewDidChange(self.textView)
            self.reloadData()
        }
    }
}
