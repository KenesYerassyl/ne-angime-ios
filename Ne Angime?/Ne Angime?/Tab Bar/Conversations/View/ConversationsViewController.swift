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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        conversationsViewModel.delegate = self
        conversationsViewModel.fetchAllConversations()
        updateCollectionView()
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
}

// Extension for collection view delegate
extension ConversationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationID = conversationsViewModel.getConversationID(at: indexPath.row)
        let chatViewController = ChatViewController(
            conversationID: conversationID,
            URL(string: UserDefaults.standard.string(forKey: "avatar") ?? ""),
            conversationsViewModel.getUserImageURL(from: conversationsViewModel.getConversationID(at: indexPath.row))
        )
        chatViewController.title = conversationsViewModel.getFullNameOfRecipient(at: indexPath.row)
        for index in 0...conversationsViewModel.conversations[indexPath.row].messages.count - 1 {
            conversationsViewModel.conversations[indexPath.row].messages[index].isSeen = true
        }
        CoreDataManager.shared.setMessagesToRead(conversationID: conversationsViewModel.getConversationID(at: indexPath.row))
        self.navigationController?.pushViewController(chatViewController, animated: true)
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

// Extension for collection view delegate floew layout
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
}

