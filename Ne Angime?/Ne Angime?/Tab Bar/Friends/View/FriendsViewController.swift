//
//  FriendsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit

class FriendsViewController: UIViewController {
    private let friendsViewModel = FriendsViewModel()
    private let titleLabel: UILabel = {
        var temp = UILabel()
        temp.font = UIFont(name: "Avenir Black", size: 35)
        return temp
    }()
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
        configureTitleLabel()
        friendsViewModel.fetchAllUsers()
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
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(UIScreen.main.bounds.width*0.9)
            make.height.equalTo(70)
            make.bottom.equalTo(collectionView.snp.top).offset(-12)
        }
        titleLabel.text = "Friends"
    }
}

extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chatViewController = ChatViewController()
        let user = friendsViewModel.getUser(at: indexPath.row)
        chatViewController.chatViewModel.otherUser = Sender(
            senderId: user.username,
            displayName: "\(user.firstname) \(user.lastname)"
        )
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
        cell.userInfo = friendsViewModel.getUser(at: indexPath.row)
        cell.userNameLabel.text = "\(cell.userInfo.firstname) \(cell.userInfo.lastname)"
        return cell
    }
}

extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

extension FriendsViewController: FriendsViewModelDelegate {
    func updateCollectionView() {
        collectionView.reloadData()
    }
}

