//
//  UsersViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/23/21.
//
import SnapKit
import NVActivityIndicatorView

class UsersViewController: ViewController {
    private let usersViewModel = UsersViewModel()
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        var temp = UICollectionViewFlowLayout()
        temp.minimumLineSpacing = 12
        temp.minimumInteritemSpacing = 12;
        return temp
    }()
    private lazy var collectionView: UICollectionView = {
        var temp = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        temp.register(UsersCollectionViewCell.self, forCellWithReuseIdentifier: UsersCollectionViewCell.id)
        return temp
    }()
    var completion: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        usersViewModel.delegate = self
        updateCollectionView()
        updateActivityIndicator(self)
        startActivityIndicator()
        usersViewModel.fetchAllUsers()
    }
    
    func updateCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        collectionView.alwaysBounceVertical = true
    }
}

// Extension for collection view delegate
extension UsersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let user = usersViewModel.getUser(at: indexPath.row)
        var isNewConversation = true
        var conversationID = "\(currentUsername)&&\(user.username)"
        
        if CoreDataManager.shared.doesConversationExist("\(user.username)&&\(currentUsername)") {
            conversationID = "\(user.username)&&\(currentUsername)"
            isNewConversation = false
        } else if CoreDataManager.shared.doesConversationExist("\(currentUsername)&&\(user.username)") {
            isNewConversation = false
        }
        let chatViewController = ChatViewController(
            conversationID: conversationID,
            URL(string: UserDefaults.standard.string(forKey: "avatar") ?? "")
        )
        chatViewController.title = "\(user.firstname) \(user.lastname)"
        dismiss(animated: true)
        if isNewConversation {
            navigationController?.pushViewController(chatViewController, animated: true)
        } else {
            guard let completion = completion else { return }
            completion(conversationID)
        }
    }
}

// Extension for collection view data source
extension UsersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return usersViewModel.getNumberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersCollectionViewCell.id, for: indexPath) as? UsersCollectionViewCell
        guard let cell = collectionViewCell else { return UICollectionViewCell() }
        let user = usersViewModel.getUser(at: indexPath.row)
        cell.userNameLabel.text = "\(user.firstname) \(user.lastname)"
        cell.userImageView.sd_setImage(
            with: usersViewModel.getUserImageURL(at: indexPath.row),
            placeholderImage: UIImage(named: "profile_placeholder")
        )
        return cell
    }
}

// Extension for collection view delegate flow layout
extension UsersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

// Extension for view model delegate
extension UsersViewController: UsersViewModelDelegate {
    func userMayInteract() {
        stopActivityIndicator()
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
}

