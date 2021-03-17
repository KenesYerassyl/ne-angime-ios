//
//  SignUpViewController2.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/14/21.
//

import UIKit
import NVActivityIndicatorView

class SignUpViewController2: ViewController {
    
    private let spacing = 24.0
    private let fieldsView = UIView()
    private let welcomeLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField1 = UITextField()
    private let passwordTextField2 = UITextField()
    private let signUpButton = UIButton()
    private var signUpViewModel2 = SignUpViewModel2()
    
    init(firstName: String, lastName: String, userName: String) {
        super.init(nibName: nil, bundle: nil)
        signUpViewModel2.firstName = firstName
        signUpViewModel2.lastName = lastName
        signUpViewModel2.userName = userName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        updateFieldsView()
        updateWelcomeLabel()
        updateEmailTextField()
        updatePasswordTextField1()
        updatePasswordTextField2()
        updateSignUpButton()
        addBackButton(withNormalColor: .normalLight, didTapBackButton: #selector(didTapBackButton))
        updateActivityIndicator(self)
        signUpViewModel2.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func updateFieldsView() {
        view.addSubview(fieldsView)
        fieldsView.backgroundColor = .white
        fieldsView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.7)
            make.bottom.equalTo(view)
        }
        fieldsView.layer.cornerRadius = 30
    }
    
    private func updateWelcomeLabel() {
        view.addSubview(welcomeLabel)
        welcomeLabel.font = UIFont(name: "Avenir Black", size: 24)
        welcomeLabel.text = "You are almost done!"
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.05)
            make.top.equalTo(fieldsView).offset(spacing)
        }
    }
    
    private func updateEmailTextField() {
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
        emailTextField.addDoneButtonOnKeyboard()
    }
    
    private func updatePasswordTextField1() {
        view.addSubview(passwordTextField1)
        passwordTextField1.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(emailTextField.snp.bottom).offset(spacing)
        }
        passwordTextField1.layer.cornerRadius = 20
        passwordTextField1.layer.borderWidth = 3
        passwordTextField1.layer.borderColor = UIColor.systemGray5.cgColor
        passwordTextField1.setRightPaddingPoints(view.bounds.width * 0.08)
        passwordTextField1.setLeftPaddingPoints(view.bounds.width * 0.08)
        passwordTextField1.font = UIFont(name: "Avenir", size: 20)
        passwordTextField1.placeholder = "Insert the password"
        passwordTextField1.isSecureTextEntry = true
        passwordTextField1.addDoneButtonOnKeyboard()
    }
    
    private func updatePasswordTextField2() {
        view.addSubview(passwordTextField2)
        passwordTextField2.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(passwordTextField1.snp.bottom).offset(spacing)
        }
        passwordTextField2.layer.cornerRadius = 20
        passwordTextField2.layer.borderWidth = 3
        passwordTextField2.layer.borderColor = UIColor.systemGray5.cgColor
        passwordTextField2.setRightPaddingPoints(view.bounds.width * 0.08)
        passwordTextField2.setLeftPaddingPoints(view.bounds.width * 0.08)
        passwordTextField2.font = UIFont(name: "Avenir", size: 20)
        passwordTextField2.placeholder = "Confirm your password"
        passwordTextField2.isSecureTextEntry = true
        passwordTextField2.addDoneButtonOnKeyboard()
    }
    
    private func updateSignUpButton() {
        view.addSubview(signUpButton)
        signUpButton.backgroundColor = UIColor(hex: "#4fa1d6")
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.65)
            make.top.equalTo(passwordTextField2.snp.bottom).offset(spacing * 2)
        }
        signUpButton.layer.cornerRadius = 20
        signUpButton.setTitle("SIGN UP", for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "Avenir Heavy", size: 20)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
}

// Extension for logic functions
extension SignUpViewController2 {
    @objc private func didTapSignUpButton() {
        startActivityIndicator()
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password1 = passwordTextField1.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password2 = passwordTextField2.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return
        }
        signUpViewModel2.email = email
        signUpViewModel2.password1 = password1
        signUpViewModel2.password2 = password2
        signUpViewModel2.signUp()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if emailTextField.isFirstResponder {
                view.frame.origin.y = -keyboardSize.height + (view.frame.height - emailTextField.frame.origin.y - emailTextField.frame.height)
            } else if passwordTextField1.isFirstResponder {
                view.frame.origin.y = -keyboardSize.height + (view.frame.height - passwordTextField1.frame.origin.y - passwordTextField1.frame.height)
            } else if passwordTextField2.isFirstResponder {
                view.frame.origin.y = -keyboardSize.height + (view.frame.height - passwordTextField2.frame.origin.y - passwordTextField2.frame.height)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

// View Model delegate Extension
extension SignUpViewController2: SignUpViewModelDelegate2 {
    
    func userMayInteract() {
        stopActivityIndicator()
    }
    
    func goToMainPage() {
        navigationController?.dismiss(animated: true)
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
