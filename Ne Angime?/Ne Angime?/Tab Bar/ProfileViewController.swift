//
//  ProfileViewController1.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 6/5/21.
//

import UIKit

class ProfileViewController: ViewController {
    
    let scrollView = UIScrollView()
    let userInfoView = UIView()
    private let profileView = UIView()
    let profileImageView = UIImageView()
    let userFullNameLabel = UILabel()
    let spacing = 24.0
    var usernameLabel: PaddingLabel!
    var emailLabel: PaddingLabel!
    var bioTextView = UITextView()
    var refreshControl = UIRefreshControl()
    let interactButton = UIButton()
    let signOutButton = UIButton()
    let settingsButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
    }
    
    func setUpProfileViewController(addInteractButton: Bool) {
        updateScrollView()
        updateUserInfoView()
        updateProfileImageView()
        updateFullUserNameLabel()
        if addInteractButton {
            updateInteractButton()
        } else {
            updateSignOutButton()
            updateSettingsButton()
        }
        updateUsernameLabel(addInteractButton: addInteractButton)
        updateEmailLabel()
        updateBioTextView()
        updateActivityIndicator(self)
        updateRefreshControl()

    }
    
    private func updateScrollView() {
        view.addSubview(scrollView)
        scrollView.backgroundColor = .clear
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
        scrollView.contentSize.height = view.bounds.height * 2
        scrollView.alwaysBounceVertical = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
    }
    
    private func updateSignOutButton() {
        scrollView.addSubview(signOutButton)
        signOutButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(scrollView).offset(spacing / 2)
            make.trailing.equalTo(view).offset(-spacing)
        }
        signOutButton.setImage(UIImage(named: "sign_out_icon_normal"), for: .normal)
        signOutButton.setImage(UIImage(named: "sign_out_icon_tapped"), for: .highlighted)
    }
    
    private func updateSettingsButton() {
        scrollView.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(scrollView).offset(spacing / 2)
            make.leading.equalTo(view).offset(spacing)
        }
        settingsButton.setImage(UIImage(named: "settings_icon_normal"), for: .normal)
        settingsButton.setImage(UIImage(named: "settings_icon_tapped"), for: .highlighted)
    }
    
    private func updateUserInfoView() {
        scrollView.addSubview(userInfoView)
        userInfoView.backgroundColor = .white
        userInfoView.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView.contentSize.height)
            make.top.equalTo(scrollView).offset(view.bounds.height * 0.4)
        }
        userInfoView.layer.cornerRadius = 30
    }
    
    private func updateInteractButton() {
        scrollView.addSubview(interactButton)
        interactButton.snp.makeConstraints { make in
            make.top.equalTo(userInfoView).offset(spacing)
            make.width.equalTo(UIScreen.main.bounds.width * 0.7)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(60)
        }
        interactButton.layer.cornerRadius = 20
        interactButton.titleLabel?.font = UIFont(name: "Avenir", size: 20)
        interactButton.layer.borderWidth = 1
        interactButton.layer.borderColor = UIColor(hex: "#30289f").cgColor
    }
    
    private func updateProfileImageView() {
        scrollView.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.backgroundColor = .gray
        profileView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.width.equalTo(view.bounds.height * 0.2)
            make.height.equalTo(view.bounds.height * 0.2)
            make.centerY.equalTo(userInfoView.snp.top).offset(-4.2*spacing - 0.1 * Double(view.bounds.height))
        }
        profileView.layer.cornerRadius = view.bounds.height * 0.08
        
        profileImageView.backgroundColor = .white
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.width.equalTo(view.bounds.height * 0.19)
            make.height.equalTo(view.bounds.height * 0.19)
            make.centerY.equalTo(userInfoView.snp.top).offset(-4.2*spacing - 0.1 * Double(view.bounds.height))
        }
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = view.bounds.height * 0.075
    }
    
    private func updateFullUserNameLabel() {
        scrollView.addSubview(userFullNameLabel)
        userFullNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(profileView.snp.bottom).offset(spacing)
        }
        userFullNameLabel.font = UIFont(name: "Avenir Light", size: 30)
        userFullNameLabel.textColor = .white
    }
    
    private func updateUsernameLabel(addInteractButton: Bool) {
        let coupleLabel = getCoupleLabel()
        scrollView.addSubview(coupleLabel.0)
        coupleLabel.0.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(addInteractButton ? interactButton.snp.bottom : userInfoView).offset(spacing)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(20)
        }
        coupleLabel.0.text = "Username"
        usernameLabel = coupleLabel.1
        scrollView.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(coupleLabel.0.snp.bottom).offset(spacing/2)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(40)
        }
    }
    
    private func updateEmailLabel() {
        let coupleLabel = getCoupleLabel()
        scrollView.addSubview(coupleLabel.0)
        coupleLabel.0.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(usernameLabel.snp.bottom).offset(spacing)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(20)
        }
        coupleLabel.0.text = "Email"
        emailLabel = coupleLabel.1
        scrollView.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(coupleLabel.0.snp.bottom).offset(spacing/2)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(40)
        }
    }
    
    private func updateBioTextView() {
        let coupleLabel = getCoupleLabel()
        scrollView.addSubview(coupleLabel.0)
        coupleLabel.0.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(emailLabel.snp.bottom).offset(spacing)
            make.centerX.equalTo(scrollView)
            make.height.equalTo(20)
        }
        coupleLabel.0.text = "Bio"
        scrollView.addSubview(bioTextView)
        bioTextView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(coupleLabel.0.snp.bottom).offset(spacing/2)
            make.centerX.equalTo(scrollView)
        }
        bioTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        bioTextView.font = UIFont(name: "Avenir Heavy", size: 20)
        bioTextView.layer.cornerRadius = 15
        bioTextView.backgroundColor = UIColor(hex: "#eeedfc")
        bioTextView.isEditable = false
        bioTextView.isScrollEnabled = false
    }
    
    private func getCoupleLabel() -> (PaddingLabel, PaddingLabel) {
        let titleLabel = PaddingLabel()
        titleLabel.font = UIFont(name: "Avenir Black", size: 20)
        let infoLabel = PaddingLabel()
        infoLabel.font = UIFont(name: "Avenir Heavy", size: 20)
        infoLabel.layer.cornerRadius = 15
        infoLabel.layer.masksToBounds = true
        infoLabel.padding(0, 0, 10, 10)
        infoLabel.textAlignment = .left
        infoLabel.numberOfLines = 0
        infoLabel.sizeToFit()
        infoLabel.backgroundColor = UIColor(hex: "#eeedfc")
        return (titleLabel, infoLabel)
    }
    private func updateRefreshControl() {
        scrollView.addSubview(refreshControl)
    }
}
