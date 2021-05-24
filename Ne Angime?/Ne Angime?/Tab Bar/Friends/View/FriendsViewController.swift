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
    private var refreshControl = UIRefreshControl()
    private let statusLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Friends", "Incoming", "Outcoming"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        collectionView.delegate = self
        collectionView.dataSource = self
        friendsViewModel.delegate = self
        
        updateSegmentedControl()
        updateCollectionView()
        updateActivityIndicator(self)
        updateRefreshControl()
        updateStatusLabel(text: "Sorry, this list is empty.")
        
        startActivityIndicator()
        friendsViewModel.fetchAllRelatedUsers()
    }
    
    private func updateSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerX.equalTo(view)
            make.width.equalTo(UIScreen.main.bounds.width * 0.9)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = UIColor(hex: "#8f87ff")
        segmentedControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
    }
    
    private func updateCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(segmentedControl.snp.bottom).offset(5)
        }
        collectionView.alwaysBounceVertical = true
    }
    
    private func updateRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    private func updateStatusLabel(text: String) {
        collectionView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalTo(collectionView)
            make.centerY.equalTo(collectionView)
            make.leading.equalTo(collectionView).offset(10)
            make.trailing.equalTo(collectionView).offset(-10)
        }
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont(name: "Avenir", size: 20)
        statusLabel.textColor = .systemGray3
        statusLabel.text = text
        statusLabel.isHidden = true
    }
}
//Extension for logic functions
extension FriendsViewController {
    @objc private func refresh() {
        startActivityIndicator()
        friendsViewModel.fetchAllRelatedUsers()
        refreshControl.endRefreshing()
    }
    
    @objc private func segmentDidChange() {
        collectionView.reloadData()
        statusChange(text: "", isTextChanged: false)
    }
}

// Extension for collection view delegate
extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let username = friendsViewModel.getUser(at: segmentedControl.selectedSegmentIndex, at: indexPath.row).username
        let userProfileViewController = UserProfileViewController(username: username)
        userProfileViewController.completion = { [weak self] in
            self?.friendsViewModel.fetchAllRelatedUsers()
        }
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
}

// Extension for collection view data source
extension FriendsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsViewModel.getNumberOfItems(at: segmentedControl.selectedSegmentIndex)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendsCollectionViewCell.id, for: indexPath) as? FriendsCollectionViewCell
        guard let cell = collectionViewCell else { return UICollectionViewCell() }
        let user = friendsViewModel.getUser(at: segmentedControl.selectedSegmentIndex, at: indexPath.row)
        cell.userNameLabel.text = "\(user.firstname) \(user.lastname)"
        cell.userImageView.sd_setImage(
            with: friendsViewModel.getUserImageURL(at: segmentedControl.selectedSegmentIndex, at: indexPath.row),
            placeholderImage: UIImage(named: "profile_placeholder")
        )
        return cell
    }
}

// Extension for collection view delegate flow layout
extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 90)
    }
}

// Extension for view model delegate
extension FriendsViewController: FriendsViewModelDelegate {
    func statusChange(text: String, isTextChanged: Bool) {
        if isTextChanged { statusLabel.text = text }
        statusLabel.isHidden = friendsViewModel.getNumberOfItems(at: segmentedControl.selectedSegmentIndex) != 0
    }
    
    func userMayInteract() {
        stopActivityIndicator()
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
}

