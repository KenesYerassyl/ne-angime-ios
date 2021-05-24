//
//  UserProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/21/21.
//

import UIKit

class UserProfileViewController: ViewController {
    
    private let userInfoView = UIView()
    private let profileView = UIView()
    private let profileImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let interactButton = UIButton()
    var completion: (() -> Void)?
    internal var username: String
    private let spacing = 24.0
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
        view.backgroundColor = UIColor(hex: "#30289f")
        addBackButton(withNormalColor: .normalLight, didTapBackButton: #selector(didTapBackButton))
        userProfileViewModel.delegate = self
        updateUserInfoView()
        updateProfileImageView()
        updateUserNameLabel()
        updateInteractButton()
        updateActivityIndicator(self)
        
        startActivityIndicator()
        userProfileViewModel.fetchUserProfile()
    }
    
    private func updateUserInfoView() {
        view.addSubview(userInfoView)
        userInfoView.backgroundColor = .white
        userInfoView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.6)
            make.bottom.equalTo(view)
        }
        userInfoView.layer.cornerRadius = 30
    }
    
    private func updateProfileImageView() {
        view.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.backgroundColor = .gray
        profileView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.height * 0.2)
            make.height.equalTo(view.bounds.height * 0.2)
            make.centerY.equalTo(userInfoView.snp.top).offset(-4.2*spacing - 0.1 * Double(view.bounds.height))
        }
        profileView.layer.cornerRadius = view.bounds.height * 0.08
        
        profileImageView.backgroundColor = .white
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.height * 0.19)
            make.height.equalTo(view.bounds.height * 0.19)
            make.centerY.equalTo(userInfoView.snp.top).offset(-4.2*spacing - 0.1 * Double(view.bounds.height))
        }
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = view.bounds.height * 0.075
        profileImageView.isUserInteractionEnabled = true
    }
    
    private func updateUserNameLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(profileView.snp.bottom).offset(spacing)
        }
        userNameLabel.font = UIFont(name: "Avenir Light", size: 30)
        userNameLabel.textColor = .white
    }
    
    private func updateInteractButton() {
        view.addSubview(interactButton)
        interactButton.snp.makeConstraints { make in
            make.top.equalTo(userInfoView).offset(spacing)
            make.width.equalTo(UIScreen.main.bounds.width * 0.7)
            make.centerX.equalTo(view)
            make.height.equalTo(60)
        }
        interactButton.layer.cornerRadius = 20
        interactButton.titleLabel?.font = UIFont(name: "Avenir", size: 20)
        interactButton.layer.borderWidth = 1
        interactButton.layer.borderColor = UIColor(hex: "#30289f").cgColor
        interactButton.addTarget(self, action: #selector(interactButtonTapped), for: .touchUpInside)
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
    
    func setUserProfile(fullName: String, avatar: URL?) {
        userNameLabel.text = fullName
        profileImageView.sd_setImage(with: avatar, placeholderImage: UIImage(named: "profile_placeholder"))
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
