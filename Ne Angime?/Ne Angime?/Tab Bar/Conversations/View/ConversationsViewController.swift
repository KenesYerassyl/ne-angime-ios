//
//  ChatsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit

class ConversationsViewController: UIViewController {
    let conversationsViewModel = ConversationsViewModel()
    private let titleLabel = UILabel()
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
        configureCollectionView()
        configureTitleLabel()
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(view).offset(130)
        }
    }
    
    func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.font = UIFont(name: "Avenir Black", size: 35)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(UIScreen.main.bounds.width*0.9)
            make.height.equalTo(70)
            make.bottom.equalTo(collectionView.snp.top).offset(-12)
        }
        titleLabel.text = "Conversations"
    }
}

extension ConversationsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversationID = conversationsViewModel.getConversationID(at: indexPath.row)
        let chatViewController = ChatViewController(conversationID: conversationID)
        let group = DispatchGroup()
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let otherUsername = UserManager.shared.getOtherUsername(from: conversationsViewModel.getConversationID(at: indexPath.row))
        group.enter()
        UserManager.shared.getImageOfUser(with: currentUsername, avatar: nil) { data in
            if let data = data {
                chatViewController.currentUserImage = UIImage(data: data)
            } else {
                chatViewController.currentUserImage = UIImage(named: "profile_placeholder")
            }
            group.leave()
        }
        group.enter()
        UserManager.shared.getImageOfUser(with: otherUsername, avatar: nil) { data in
            if let data = data {
                chatViewController.otherUserImage = UIImage(data: data)
            } else {
                chatViewController.otherUserImage = UIImage(named: "profile_placeholder")
            }
            group.leave()
        }
        group.notify(queue: .main) {
            self.navigationController?.pushViewController(chatViewController, animated: true)
        }
    }
}

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
        conversationsViewModel.getFullNameOfRecipient(at: indexPath.row) { name in
            cell.userNameLabel.text = name
        }
        let username = UserManager.shared.getOtherUsername(from: conversationsViewModel.conversations[indexPath.row].conversationID)
        UserManager.shared.getImageOfUser(with: username, avatar: nil) { data in
            if let data = data {
                DispatchQueue.main.async { cell.userImageView.image = UIImage(data: data) }
            } else {
                DispatchQueue.main.async { cell.userImageView.image = UIImage(named: "profile_placeholder") }
            }
        }
        return cell
    }
}

extension ConversationsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

extension ConversationsViewController: ConversationsViewModelDelegate {
    func updateCollectionView() {
        collectionView.reloadData()
    }
}
