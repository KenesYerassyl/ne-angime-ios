//
//  FindViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit

class FindViewController: ViewController {
    private let findViewModel = FindViewModel()
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
    private let searchBar = UISearchBar()
    private let statusLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.titleView = searchBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        findViewModel.delegate = self
        updateCollectionView()
        updateSearchBar()
        updateNoResultsLabels()
        updateActivityIndicator(self)
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
    
    func updateSearchBar() {
        view.addSubview(searchBar)
        searchBar.placeholder = "Type a name here"
        searchBar.searchTextField.addDoneButtonOnKeyboard()
    }
    
    func updateNoResultsLabels() {
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }
        statusLabel.font = UIFont(name: "Avenir", size: 20)
        statusLabel.textColor = .systemGray3
        statusLabel.text = "Guess you want to find new friends?"
    }
}
// Extension for collection view delegate
extension FindViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let user = findViewModel.getUser(at: indexPath.row)
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
// Extension for collection view data source
extension FindViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return findViewModel.getNumberOfItems()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsCollectionViewCell.id, for: indexPath) as? FriendsCollectionViewCell
        guard let cell = collectionViewCell else { return UICollectionViewCell() }
        let user = findViewModel.getUser(at: indexPath.row)
        cell.userNameLabel.text = "\(user.firstname) \(user.lastname)"
        cell.userImageView.sd_setImage(
            with: findViewModel.getUserImageURL(at: indexPath.row),
            placeholderImage: UIImage(named: "profile_placeholder")
        )
        return cell
    }
}

// Extension for collection view delegate flow layout
extension FindViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}
// Extension for search bar delegate
extension FindViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        statusLabel.isHidden = true
        searchBar.resignFirstResponder()
        startActivityIndicator()
        searchBar.isUserInteractionEnabled = false
        findViewModel.fetchUsers(with: text.lowercased())
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
    }
}
// Extension for view model delegate
extension FindViewController: FindViewModelDelegate {
    func noResultsFound() {
        statusLabel.text = "Sorry, we couldn't find anything"
        statusLabel.isHidden = false
    }
    
    func userMayInteract() {
        searchBar.isUserInteractionEnabled = true
        stopActivityIndicator()
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
}
// Extension for logic functions
extension FindViewController {
    @objc func clearButtonClicked() {
        guard !isActivityIndicatorActive() else { return }
        searchBar.text = nil
        findViewModel.users.removeAll()
        collectionView.reloadData()
        statusLabel.text = "Guess you want to find new friends?"
        statusLabel.isHidden = false
        searchBar.resignFirstResponder()
    }
}
