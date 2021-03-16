//
//  FriendsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit
import NVActivityIndicatorView

class FriendsViewController: ViewController {
    private let friendsViewModel = FriendsViewModel()
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        var temp = UICollectionViewFlowLayout()
        temp.minimumLineSpacing = 12
        temp.minimumInteritemSpacing = 12;
        return temp
    }()
    private lazy var collectionView: UICollectionView = {
        var temp = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        temp.register(FriendsCollectionViewCell.self, forCellWithReuseIdentifier: FriendsCollectionViewCell.id)
        return temp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        friendsViewModel.delegate = self
        configureCollectionView()
        updateActivityIndicator(self)
        startActivityIndicator()
        friendsViewModel.fetchAllUsers()
    }
    
    func configureCollectionView() {
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

extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let user = friendsViewModel.getUser(at: indexPath.row)
        var conversationID = "\(currentUsername)&&\(user.username)"
        
        if CoreDataManager.shared.doesConversationExist("\(user.username)&&\(currentUsername)") {
            conversationID = "\(user.username)&&\(currentUsername)"
        }
        
        let chatViewController = ChatViewController(
            conversationID: conversationID,
            URL(string: UserDefaults.standard.string(forKey: "avatar") ?? ""),
            URL(string: user.avatar ?? "")
        )
        chatViewController.title = "\(user.firstname) \(user.lastname)"
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}

extension FriendsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsViewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsCollectionViewCell.id, for: indexPath) as? FriendsCollectionViewCell
        guard let cell = collectionViewCell else { return UICollectionViewCell() }
        let user = friendsViewModel.getUser(at: indexPath.row)
        cell.userNameLabel.text = "\(user.firstname) \(user.lastname)"
        cell.userImageView.sd_setImage(
            with: friendsViewModel.getUserImageURL(at: indexPath.row),
            placeholderImage: UIImage(named: "profile_placeholder")
        )
        return cell
    }
}

extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

extension FriendsViewController: FriendsViewModelDelegate {
    func userMayInteract() {
        stopActivityIndicator()
    }
    
    func updateCollectionView() {
        collectionView.reloadData()
    }
}

