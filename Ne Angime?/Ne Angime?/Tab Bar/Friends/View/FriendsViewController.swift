//
//  FriendsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit
import NVActivityIndicatorView

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
    private let activityIndicator: NVActivityIndicatorView = {
        var temp = NVActivityIndicatorView(frame: .zero,
                                           type: .circleStrokeSpin,
                                           color: .blue,
                                           padding: nil)
        return temp
    }()
    private let backView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        friendsViewModel.delegate = self
        
        configureCollectionView()
        configureTitleLabel()
        updateActivityIndicator()
        friendsViewModel.fetchAllUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if friendsViewModel.users.isEmpty {
            activityIndicator.startAnimating()
            backView.isHidden = false
            view.isUserInteractionEnabled = false
            friendsViewModel.fetchAllUsers()
        }
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
    
    private func updateActivityIndicator() {
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.25)
            make.height.equalTo(view.bounds.width * 0.25)
        }
        backView.isHidden = true
        backView.layer.cornerRadius = 10
        backView.backgroundColor = UIColor(hex: "#5896f2")
        backView.layer.opacity = 0.8
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.15)
            make.height.equalTo(view.bounds.width * 0.15)
        }
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
        
        let chatViewController = ChatViewController(conversationID: conversationID)
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
        UserManager.shared.getImageOfUser(with: user.username, avatar: user.avatar) { (data) in
            if let data = data {
                DispatchQueue.main.async { cell.userImageView.image = UIImage(data: data) }
            } else {
                DispatchQueue.main.async { cell.userImageView.image = UIImage(named: "profile_placeholder") }
            }
        }
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
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        backView.isHidden = true
    }
    
    func updateCollectionView() {
        collectionView.reloadData()
    }
}

