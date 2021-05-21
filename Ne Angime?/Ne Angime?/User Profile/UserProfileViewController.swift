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
    private var userFullName: String
    private var userAvatar: URL?
    private var username: String
    private let spacing = 24.0
    private let userProfileViewModel = UserProfileViewModel()
    
    init(username: String, userFullName: String, userAvatar: URL?) {
        self.userFullName = userFullName
        self.username = username
        self.userAvatar = userAvatar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        userProfileViewModel.delegate = self
        updateUserInfoView()
        updateProfileImageView()
        updateUserNameLabel()
        updateActivityIndicator(self)
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
        profileImageView.sd_setImage(with: userAvatar, placeholderImage: UIImage(named: "profile_placeholder"))
    }
    
    private func updateUserNameLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(profileView.snp.bottom).offset(spacing)
        }
        userNameLabel.font = UIFont(name: "Avenir Light", size: 30)
        userNameLabel.text = self.userFullName
        userNameLabel.textColor = .white
    }
}

// Extension for View Model delegate
extension UserProfileViewController: UserProfileViewModelDelegate {
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
