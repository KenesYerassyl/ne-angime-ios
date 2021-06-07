//
//  ProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/2/21.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class MyProfileViewController: ViewController {
    
    private let scrollView = UIScrollView()
    private let userInfoView = UIView()
    private let profileView = UIView()
    private let profileImageView = UIImageView()
    private let userFullNameLabel = UILabel()
    private let signOutButton = UIButton()
    private let settingsButton = UIButton()
    private let spacing = 24.0
    private let profileViewModel = ProfileViewModel()
    private var usernameLabel: PaddingLabel!
    private var emailLabel: PaddingLabel!
    private var bioTextView = UITextView()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        profileViewModel.delegate = self
        updateScrollView()
        updateUserInfoView()
        updateProfileImageView()
        updateFullUserNameLabel()
        updateSignOutButton()
        updateSettingsButton()
        updateUsernameLabel()
        updateEmailLabel()
        updateBioTextView()
        updateActivityIndicator(self)
        updateRefreshControl()
        
        profileViewModel.fetchProfileInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        profileImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImageView.addGestureRecognizer(gesture)
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
    
    private func updateSignOutButton() {
        view.addSubview(signOutButton)
        signOutButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(spacing / 2)
            make.trailing.equalTo(view).offset(-spacing)
        }
        signOutButton.setImage(UIImage(named: "sign_out_icon_normal"), for: .normal)
        signOutButton.setImage(UIImage(named: "sign_out_icon_tapped"), for: .highlighted)
        signOutButton.addTarget(self, action: #selector(signOutButtonDidTap), for: .touchUpInside)
    }
    
    private func updateSettingsButton() {
        scrollView.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(spacing / 2)
            make.leading.equalTo(scrollView).offset(spacing)
        }
        settingsButton.setImage(UIImage(named: "settings_icon_normal"), for: .normal)
        settingsButton.setImage(UIImage(named: "settings_icon_tapped"), for: .highlighted)
        settingsButton.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
    }
    
    private func updateUsernameLabel() {
        let coupleLabel = getCoupleLabel()
        scrollView.addSubview(coupleLabel.0)
        coupleLabel.0.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width * 0.85)
            make.top.equalTo(userInfoView).offset(spacing)
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
        bioTextView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        scrollView.addSubview(refreshControl)
    }
}

// Extension for logic functions
extension MyProfileViewController {
    @objc private func refresh() {
        startActivityIndicator()
        profileViewModel.fetchProfileInformation()
        refreshControl.endRefreshing()
    }
    
    @objc private func signOutButtonDidTap() {
        NotificationCenter.default.post(name: .signOut, object: nil)
    }
    
    @objc private func didTapProfileImageView() {
        profileImageViewActionSheet()
    }
    
    @objc private func settingsButtonDidTap() {
        let settingsViewController = SettingsViewController()
        settingsViewController.completion = { [weak self] in
            self?.refresh()
        }
        settingsViewController.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
}

// Extension for View Model delegate
extension MyProfileViewController: ProfileViewModelDelegate {
    func updateProfilePage(url: URL?, fullname: String, username: String, email: String, bio: String) {
        profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_placeholder"))
        userFullNameLabel.text = fullname
        usernameLabel.text = username
        emailLabel.text = email
        bioTextView.text = bio
        stopActivityIndicator()
    }
    func userMayInteract() {
        stopActivityIndicator()
    }
    
    func setImageWith(url: URL?) {
        profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile_placeholder"))
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
}

// Extensions for image picker and navigation controller delegates
extension MyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func profileImageViewActionSheet() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "How would you like to select a picture",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.selectPhoto(from: .camera)
                }
            )
        )
        actionSheet.addAction(
            UIAlertAction(
                title: "Choose Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.selectPhoto(from: .photoLibrary)
                }
            )
        )
        present(actionSheet, animated: true)
    }
    
    private func selectPhoto(from sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        guard let imageData = selectedImage.pngData() else { return }
        
        startActivityIndicator()
        
        profileViewModel.uploadImage(imageData: imageData.base64EncodedString())
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
