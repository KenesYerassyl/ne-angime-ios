//
//  SignUpViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    private let signInViewModel = SignInViewModel()
    private let spacing = 24.0
    private let fieldsView = UIView()
    private let welcomeLabel = UILabel()
    private let userNameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton = UIButton()
    private let signUpLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        signInViewModel.delegate = self
        
        updateFieldsView()
        updateWelcomeLabel()
        updateUserNameTextField()
        updatePasswordTextField()
        updateSignInButton()
        updateSignUpLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updateFieldsView() {
        view.addSubview(fieldsView)
        fieldsView.backgroundColor = .white
        fieldsView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.6)
            make.bottom.equalTo(view)
        }
        fieldsView.layer.cornerRadius = 30
    }
    
    func updateWelcomeLabel() {
        view.addSubview(welcomeLabel)
        welcomeLabel.font = UIFont(name: "Avenir Black", size: 24)
        welcomeLabel.text = "Welcome negroe!"
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.05)
            make.top.equalTo(fieldsView).offset(spacing)
        }
    }
    
    func updateUserNameTextField() {
        view.addSubview(userNameTextField)
        userNameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(spacing*2)
        }
        userNameTextField.layer.cornerRadius = 20
        userNameTextField.layer.borderWidth = 3
        userNameTextField.layer.borderColor = UIColor.systemGray5.cgColor
        userNameTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        userNameTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        userNameTextField.font = UIFont(name: "Avenir", size: 20)
        userNameTextField.placeholder = "Insert your username"
    }
    
    func updatePasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(userNameTextField.snp.bottom).offset(spacing)
        }
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.layer.borderWidth = 3
        passwordTextField.layer.borderColor = UIColor.systemGray5.cgColor
        passwordTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        passwordTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        passwordTextField.font = UIFont(name: "Avenir", size: 20)
        passwordTextField.placeholder = "Insert your password"
        passwordTextField.isSecureTextEntry = true
    }
    
    func updateSignInButton() {
        view.addSubview(signInButton)
        signInButton.backgroundColor = UIColor(hex: "#4fa1d6")
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.65)
            make.top.equalTo(passwordTextField.snp.bottom).offset(spacing * 2)
        }
        signInButton.layer.cornerRadius = 20
        signInButton.setTitle("SIGN IN", for: .normal)
        signInButton.titleLabel?.font = UIFont(name: "Avenir Heavy", size: 20)
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
    }
    
    func updateSignUpLabel() {
        let customTextLabel = UILabel()
        view.addSubview(customTextLabel)
        view.addSubview(signUpLabel)
        customTextLabel.text = "Don't have an account?"
        customTextLabel.font = UIFont(name: "Avenir Heavy", size: 18)
        customTextLabel.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(spacing)
            make.leading.equalTo(signInButton)
        }
        signUpLabel.text = "Register"
        signUpLabel.font = UIFont(name: "Avenir Heavy", size: 18)
        signUpLabel.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(spacing)
            make.leading.equalTo(customTextLabel.snp.trailing).offset(5)
        }
        signUpLabel.textColor = UIColor(hex: "#30289f")
        signUpLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSignUpLabel))
        signUpLabel.addGestureRecognizer(tap)
    }
}

extension SignInViewController {
    @objc func didTapSignInButton() {
        guard let username = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            //TODO: show error –> i.e not all fields are filled
            return
        }
        signInViewModel.signIn(username: username, password: password)
    }
    
    @objc func didTapSignUpLabel() {
        navigationController?.pushViewController(SignUpViewController1(), animated: true)
    }
}

extension SignInViewController: SignInViewModelDelegate {
    
}
