//
//  SignUpViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit
import NVActivityIndicatorView

class SignInViewController: ViewController {
    
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
        navigationController?.delegate = self
        updateFieldsView()
        updateWelcomeLabel()
        updateUserNameTextField()
        updatePasswordTextField()
        updateSignInButton()
        updateSignUpLabel()
        updateActivityIndicator(self)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if UserDefaults.standard.string(forKey: "username") != nil {
            let tabBarController = TabBarController()
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.pushViewController(tabBarController, animated: false)
        }
    }
    
    private func updateFieldsView() {
        view.addSubview(fieldsView)
        fieldsView.backgroundColor = .white
        fieldsView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.6)
            make.bottom.equalTo(view)
        }
        fieldsView.layer.cornerRadius = 30
    }
    
    private func updateWelcomeLabel() {
        view.addSubview(welcomeLabel)
        welcomeLabel.font = UIFont(name: "Avenir Black", size: 24)
        welcomeLabel.text = "Welcome negroe!"
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.05)
            make.top.equalTo(fieldsView).offset(spacing)
        }
    }
    
    private func updateUserNameTextField() {
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
        userNameTextField.addDoneButtonOnKeyboard()
    }
    
    private func updatePasswordTextField() {
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
        passwordTextField.addDoneButtonOnKeyboard()
    }
    
    private func updateSignInButton() {
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
    
    private func updateSignUpLabel() {
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

// Extension for logic functions
extension SignInViewController {
    @objc private func didTapSignInButton() {
        startActivityIndicator()
        guard let username = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return
        }
        signInViewModel.signIn(username: username, password: password)
    }
    
    @objc private func didTapSignUpLabel() {
        let navigationController = UINavigationController(rootViewController: SignUpViewController1())
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.setNavigationBarHidden(true, animated: false)
        present(navigationController, animated: true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if passwordTextField.isFirstResponder {
                view.frame.origin.y = -keyboardSize.height + (view.frame.height - passwordTextField.frame.origin.y - passwordTextField.frame.height)
            } else if userNameTextField.isFirstResponder {
                view.frame.origin.y = -keyboardSize.height + (view.frame.height - userNameTextField.frame.origin.y - userNameTextField.frame.height)
            }
            view.frame.origin.y = min(view.frame.origin.y, 0)
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

// View Model delegate Extension
extension SignInViewController: SignInViewModelDelegate {
    
    func userMayInteract() {
        stopActivityIndicator()
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
    
    func goToMainPage() {
        userNameTextField.text = nil
        passwordTextField.text = nil
        let tabBarController = TabBarController()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(tabBarController, animated: true)
    }
}

//Navigation Controller delegate extensions
extension SignInViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        item.tintColor = UIColor(hex: "#30289f")
        viewController.navigationItem.backBarButtonItem = item
    }
}
