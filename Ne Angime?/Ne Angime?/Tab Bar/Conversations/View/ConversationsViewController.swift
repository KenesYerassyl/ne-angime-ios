//
//  ChatsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit

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
    
    func updateCollectionView() {
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
    
    func updateNewConversationButton() {
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
}
// Extension for collection view delegate
extension ConversationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationID = conversationsViewModel.getConversationID(at: indexPath.row)
        let chatViewController = ChatViewController(
            conversationID: conversationID,
            URL(string: UserDefaults.standard.string(forKey: "avatar") ?? "")
        )
        chatViewController.title = conversationsViewModel.getFullNameOfRecipient(at: indexPath.row)
        let group = DispatchGroup()
        var completed = true
        for index in 0...conversationsViewModel.conversations[indexPath.row].messages.count - 1 {
            if !conversationsViewModel.conversations[indexPath.row].messages[index].isSeen {
                group.enter()
                WebSocket.shared.sendMessageStatus(
                    message: conversationsViewModel.conversations[indexPath.row].messages[index],
                    conversationID: conversationID)
                { [weak self] result in
                    if result == .success, let self = self {
                        self.conversationsViewModel.conversations[indexPath.row].messages[index].isSeen = true
                    } else {
                        completed = false
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
            if completed {
                CoreDataManager.shared.addMessages(
                    to: conversationID,
                    from: self.conversationsViewModel.conversations[indexPath.row].messages
                ) { _ in }
            }
        }
        self.navigationController?.pushViewController(chatViewController, animated: true)
        reloadCollectionView()
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

