//
//  ChatsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit
import MapKit

class ConversationsViewController: ViewController {
    let conversationsViewModel = ConversationsViewModel()
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        var temp = UICollectionViewFlowLayout()
        temp.minimumLineSpacing = 12
        temp.minimumInteritemSpacing = 12;
        return temp
    }()
    private lazy var collectionView: UICollectionView = {
        var temp = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        temp.register(ConversationsCollectionViewCell.self, forCellWithReuseIdentifier: ConversationsCollectionViewCell.id)
        return temp
    }()
    private let newConversationButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(createTemporaryConversation), name: .temporaryConversationCreated, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        conversationsViewModel.delegate = self
        conversationsViewModel.fetchAllConversations()
        updateCollectionView()
        updateNewConversationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollectionView()
    }
    
    private func updateCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.alwaysBounceVertical = true
    }
    
    private func updateNewConversationButton() {
        view.addSubview(newConversationButton)
        newConversationButton.snp.makeConstraints { make in
            guard let myTabBarController = self.tabBarController else { return }
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.bottom.equalTo(view).offset(-12 - myTabBarController.tabBar.bounds.height * 2)
            make.trailing.equalTo(view).offset(-24)
        }
        newConversationButton.titleLabel?.textAlignment = .center
        newConversationButton.layer.cornerRadius = 30
        newConversationButton.backgroundColor = UIColor(hex: "#30289f")
        newConversationButton.titleLabel?.font = UIFont(name: "Avenir", size: 24)
        newConversationButton.setTitle("+", for: .normal)
        newConversationButton.setTitleColor(.white, for: .normal)
        newConversationButton.setTitle("+", for: .highlighted)
        newConversationButton.setTitleColor(UIColor(hex: "#aba7f3"), for: .highlighted)
        newConversationButton.addTarget(self, action: #selector(newConversationButtonClicked), for: .touchUpInside)
    }
}
// Extension for logics functions
extension ConversationsViewController {
    @objc private func newConversationButtonClicked() {
        let usersViewController = UsersViewController()
        usersViewController.completion = { [weak self] conversationID in
            guard let self = self else { return }
            for row in stride(from: 0, to: self.conversationsViewModel.getNumberOfItems(), by: 1) {
                if self.conversationsViewModel.getConversationID(at: row) == conversationID {
                    let indexPath = IndexPath(row: row, section: 0)
                    DispatchQueue.main.async {
                        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
                    }
                    break
                }
            }
        }
        present(usersViewController, animated: true)
    }
    
    @objc private func createTemporaryConversation(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String,
              let title = userInfo["title"] as? String else { return }
        pushChatViewController(conversationID: conversationID, title: title)
    }
    
    private func pushChatViewController(conversationID: String, title: String) {
        let chatViewController = ChatViewController(conversationID: conversationID)
        chatViewController.title = title
        
        chatViewController.completion = { [weak self] conversationIDToBeChanged, messageID in
            guard let self = self else { return }
            for jndex in stride(from: 0, to: self.conversationsViewModel.conversations.count, by: 1) {
                if self.conversationsViewModel.conversations[jndex].conversationID == conversationIDToBeChanged,
                   let messageToBeUpdated = self.conversationsViewModel.conversations[jndex].getMessage(by: messageID) {
                    WebSocket.shared.sendMessageStatus(
                        message: messageToBeUpdated,
                        conversationID: conversationIDToBeChanged)
                    { [weak self] result in
                        guard result == .success, let self = self else { return }
                        self.conversationsViewModel.conversations[jndex].setMessageStatusSeen(with: messageID)
                        autoreleasepool {
                            let realm = RealmManager()
                            realm.database.refresh()
                            realm.setMessageStatusSeen(
                                from: conversationIDToBeChanged,
                                messageID: messageToBeUpdated.messageID
                            )
                        }
                    }
                    break
                }
            }
        }
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func locationButtonClicked() {
        navigationController?.pushViewController(LocationViewController(), animated: true)
    }
}
// Extension for collection view delegate
extension ConversationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushChatViewController(
            conversationID: conversationsViewModel.getConversationID(at: indexPath.row),
            title: conversationsViewModel.getFullNameOfRecipient(at: indexPath.row)
        )
    }
}

// Extension for collection view data source
extension ConversationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversationsViewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ConversationsCollectionViewCell.id, for: indexPath) as? ConversationsCollectionViewCell
        guard let cell = collectionViewCell else {
            return UICollectionViewCell()
        }
        cell.userMessageLabel.text = ""
        cell.userNameLabel.text = ""
        
        
        cell.userMessageLabel.text = conversationsViewModel.getLastMessage(at: indexPath.row)
        cell.userNameLabel.text = conversationsViewModel.getFullNameOfRecipient(at: indexPath.row)
        cell.newMessagesCounter = conversationsViewModel.getNumberOfUnreadMessages(at: indexPath.row)
        cell.userImageView.sd_setImage(
            with: conversationsViewModel.getUserImageURL(from: conversationsViewModel.getConversationID(at: indexPath.row)),
            placeholderImage: UIImage(named: "profile_placeholder")
        )
        return cell
    }
}

// Extension for collection view delegate flow layout
extension ConversationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

// Extension for view model delegate
extension ConversationsViewController: ConversationsViewModelDelegate {
    func reloadCollectionView() {
        conversationsViewModel.conversations.sort { (conversation1, conversation2) -> Bool in
            return conversation1 > conversation2
        }
        collectionView.reloadData()
    }
    
    func inChatViewController(with conversationID: String) -> Bool {
        var validation = false
        DispatchQueue.main.async {
            if self.navigationController?.topViewController?.view.tag == 88,
               let chatViewController = self.navigationController?.topViewController as? ChatViewController,
               chatViewController.chatViewModel.conversationID == conversationID {
                validation = true
            } else {
                validation = false
            }
        }
        return validation
    }
}

