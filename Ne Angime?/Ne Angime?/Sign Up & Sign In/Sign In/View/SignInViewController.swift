//
//  SignUpViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit

class SignInViewController: UIViewController {
    
    private let spacing = 24.0
    private var fieldsView = UIView()
    private var welcomeLabel = UILabel()
    private var emailTextField = UITextField()
    private var passwordTextField = UITextField()
    private var signInButton = UIButton()
    private var signUpLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        updateFieldsView()
        updateWelcomeLabel()
        updateEmailTextField()
        updatePasswordTextField()
        updateSignInButton()
        updateSignUpLabel()
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
    
    func updateEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(spacing*2)
        }
        emailTextField.layer.cornerRadius = 20
        emailTextField.layer.borderWidth = 3
        emailTextField.layer.borderColor = UIColor.systemGray5.cgColor
        emailTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        emailTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        emailTextField.font = UIFont(name: "Avenir", size: 20)
        emailTextField.placeholder = "Insert your email"
    }
    
    func updatePasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(emailTextField.snp.bottom).offset(spacing)
        }
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.layer.borderWidth = 3
        passwordTextField.layer.borderColor = UIColor.systemGray5.cgColor
        passwordTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        passwordTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        passwordTextField.font = UIFont(name: "Avenir", size: 20)
        passwordTextField.placeholder = "Insert your password"
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
    }
}
