//
//  ProfileViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/2/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let userInfoView = UIView()
    private let profileView = UIView()
    private let profileImageView = UIImageView()
    private let spacing = 24.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        updateUserInfoView()
        updateProfileView()
        updateProfileImageView()
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
    
    private func updateProfileView() {
        view.addSubview(profileView)
        profileView.backgroundColor = .gray
        profileView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.height * 0.25)
            make.height.equalTo(view.bounds.height * 0.25)
            make.centerY.equalTo(userInfoView.snp.top).offset(-2*spacing - 0.125 * Double(view.bounds.height))
        }
        profileView.layer.cornerRadius = view.bounds.height * 0.125
    }
    
    private func updateProfileImageView() {
        profileView.addSubview(profileImageView)
        profileImageView.backgroundColor = .white
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.height * 0.24)
            make.height.equalTo(view.bounds.height * 0.24)
            make.centerY.equalTo(userInfoView.snp.top).offset(-2*spacing - 0.125 * Double(view.bounds.height))
        }
        profileImageView.layer.cornerRadius = view.bounds.height * 0.12
    }
}
