//
//  ProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/2/21.
//

import UIKit
import NVActivityIndicatorView

class ProfileViewController: UIViewController {
    
    private let userInfoView = UIView()
    private let profileView = UIView()
    private let profileImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let signOutButton = UIButton()
    private let spacing = 24.0
    private let profileViewModel = ProfileViewModel()
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
        view.backgroundColor = UIColor(hex: "#30289f")
        profileViewModel.delegate = self
        updateUserInfoView()
        updateProfileImageView()
        updateUserNameLabel()
        updateSignOutButton()
        updateActivityIndicator()
        profileViewModel.downloadImage()
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
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImageView.addGestureRecognizer(gesture)
    }
    
    private func updateUserNameLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(profileView.snp.bottom).offset(spacing)
        }
        userNameLabel.font = UIFont(name: "Avenir Light", size: 30)
        let userFullName = profileViewModel.getUserFullName()
        userNameLabel.text = "\(userFullName.0) \(userFullName.1)"
        userNameLabel.textColor = .white
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
        signOutButton.setImage(UIImage(named: "sign_out_icon_tapped"), for: .selected)
        signOutButton.setImage(UIImage(named: "sign_out_icon_tapped"), for: .highlighted)
        signOutButton.addTarget(self, action: #selector(signOutButtonDidTap), for: .touchUpInside)
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

extension ProfileViewController {
    @objc private func signOutButtonDidTap() {
        profileViewModel.signOut()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapProfileImageView() {
        profileImageViewActionSheet()
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func setProfileImage(with data: Data) {
        guard let image = UIImage(data: data) else { return }
        profileImageView.image = image
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

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        activityIndicator.startAnimating()
        backView.isHidden = false
        view.isUserInteractionEnabled = false
        
        profileViewModel.uploadImage(imageData: imageData.base64EncodedString()) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.backView.isHidden = true
                self?.view.isUserInteractionEnabled = true
            }
            if result { self?.profileImageView.image = selectedImage }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
