//
//  ProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/2/21.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class MyProfileViewController: ProfileViewController {

    private let myProfileViewModel = MyProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfileViewController(addInteractButton: false)
        view.backgroundColor = UIColor(hex: "#30289f")
        myProfileViewModel.delegate = self
        
        profileImageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImageView.addGestureRecognizer(gesture)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        signOutButton.addTarget(self, action: #selector(signOutButtonDidTap), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)
        
        myProfileViewModel.fetchProfileInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// Extension for logic functions
extension MyProfileViewController {
    @objc private func refresh() {
        startActivityIndicator()
        myProfileViewModel.fetchProfileInformation()
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
extension MyProfileViewController: MyProfileViewModelDelegate {
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
        
        myProfileViewModel.uploadImage(imageData: imageData.base64EncodedString())
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
