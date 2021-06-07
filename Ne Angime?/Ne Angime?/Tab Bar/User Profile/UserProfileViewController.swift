//
//  UserProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/21/21.
//

import UIKit

class UserProfileViewController: ProfileViewController {
    
    var completion: (() -> Void)?
    internal var username: String
    private let userProfileViewModel = UserProfileViewModel()
    
    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfileViewController(addInteractButton: true)
        view.backgroundColor = UIColor(hex: "#30289f")
        addBackButton(withNormalColor: .normalLight, didTapBackButton: #selector(didTapBackButton))
        userProfileViewModel.delegate = self
        
        interactButton.addTarget(self, action: #selector(interactButtonTapped), for: .touchUpInside)
        
        startActivityIndicator()
        userProfileViewModel.fetchUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
// Extension for logic functions
extension UserProfileViewController {
    @objc private func interactButtonTapped() {
        startActivityIndicator()
        userProfileViewModel.changeRelation()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

// Extension for View Model delegate
extension UserProfileViewController: UserProfileViewModelDelegate {
    func setStatus(_ newStatus: FriendStatus, refreshingList: Bool) {
        switch newStatus {
        case .friend:
            interactButton.backgroundColor = UIColor(hex: "#f4f5fa")
            interactButton.setTitle("Remove from friends", for: .normal)
            interactButton.setTitleColor(.black, for: .normal)
        case .incomingRequest:
            interactButton.backgroundColor = UIColor(hex: "#30289f")
            interactButton.setTitle("Approve request", for: .normal)
            interactButton.setTitleColor(.white, for: .normal)
        case .outcomingRequest:
            interactButton.backgroundColor = UIColor(hex: "#f4f5fa")
            interactButton.setTitle("Cancel request", for: .normal)
            interactButton.setTitleColor(.black, for: .normal)
        case.noRelation:
            interactButton.backgroundColor = UIColor(hex: "#30289f")
            interactButton.setTitle("Send request", for: .normal)
            interactButton.setTitleColor(.white, for: .normal)
        }
        if refreshingList { completion?() }
    }
    
    func setUserProfile(fullName: String, avatar: URL?, username: String, email: String, bio: String) {
        userFullNameLabel.text = fullName
        profileImageView.sd_setImage(with: avatar, placeholderImage: UIImage(named: "profile_placeholder"))
        usernameLabel.text = username
        emailLabel.text = email
        bioTextView.text = bio
    }
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func userMayInteract() {
        stopActivityIndicator()
    }
}
