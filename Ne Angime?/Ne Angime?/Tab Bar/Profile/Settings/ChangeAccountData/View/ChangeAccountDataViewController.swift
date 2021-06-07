//
//  ChangeAccountDataViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 6/3/21.
//

import UIKit

class ChangeAccountDataViewController: ViewController {
    
    private let spacing = 24.0
    private let bioTextView = UITextView()
    private var passwordTextField1 = UITextField()
    private var passwordTextField2 = UITextField()
    private var passwordTextField3 = UITextField()
    private var firstnameTextField = UITextField()
    private var lastnameTextField = UITextField()
    private var emailTextField = UITextField()
    private var editableData: String
    private let doneButton = UIButton()
    private var keyboardHeight: CGFloat?
    private let changeAccountDataViewModel = ChangeAccountDataViewModel()
    private lazy var safeAreaOriginY: CGFloat = {
        let temp = view.safeAreaLayoutGuide.layoutFrame.origin.y
        return temp
    }()
    private let characterLimit = 250
    var completion: (() -> Void)?
    
    init(_ dataToChange: String) {
        self.editableData = dataToChange
        super.init(nibName: nil, bundle: nil)
        self.title = dataToChange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAccountDataViewModel.delegate = self
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        switch editableData {
        case "Bio":
            updateBioTextView()
        case "First Name":
            updateFirstnameTextField()
        case "Last Name":
            updateLastnameTextField()
        case "Password":
            updatePasswordTextField()
        case "Email":
            updateEmailTextField()
        default:
            fatalError()
        }
        updateDoneButton()
        
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
    
    private func getTextField(with placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = 20
        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.setRightPaddingPoints(view.bounds.width * 0.08)
        textField.setLeftPaddingPoints(view.bounds.width * 0.08)
        textField.font = UIFont(name: "Avenir", size: 20)
        textField.placeholder = placeholder
        textField.addDoneButtonOnKeyboard()
        return textField
    }
    
    private func updateBioTextView() {
        view.addSubview(bioTextView)
        bioTextView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(spacing)
        }
        bioTextView.layer.cornerRadius = 20
        bioTextView.layer.borderWidth = 3
        bioTextView.layer.borderColor = UIColor.systemGray5.cgColor
        bioTextView.textContainerInset = UIEdgeInsets(top: 10, left: view.bounds.width * 0.08, bottom: 10, right: view.bounds.width * 0.08)
        bioTextView.font = UIFont(name: "Avenir", size: 20)
        bioTextView.isScrollEnabled = false
        bioTextView.delegate = self
        bioTextView.addDoneButtonOnKeyboard()
        bioTextView.text = UserDefaults.standard.string(forKey: "bio") ?? ""
    }
    private func updatePasswordTextField() {
        passwordTextField1 = getTextField(with: "Enter your current password")
        view.addSubview(passwordTextField1)
        passwordTextField1.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(spacing)
        }
        passwordTextField2 = getTextField(with: "Enter your new password")
        view.addSubview(passwordTextField2)
        passwordTextField2.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(passwordTextField1.snp.bottom).offset(spacing*2)
        }
        passwordTextField3 = getTextField(with: "Confirm your new password")
        view.addSubview(passwordTextField3)
        passwordTextField3.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(passwordTextField2.snp.bottom).offset(spacing*2)
        }
    }
    private func updateFirstnameTextField() {
        firstnameTextField = getTextField(with: "")
        view.addSubview(firstnameTextField)
        firstnameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(spacing)
        }
        guard let firstname = UserDefaults.standard.string(forKey: "firstname") else { fatalError() }
        firstnameTextField.text = firstname
    }
    private func updateLastnameTextField() {
        lastnameTextField = getTextField(with: "")
        view.addSubview(lastnameTextField)
        lastnameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(spacing)
        }
        guard let lastname = UserDefaults.standard.string(forKey: "lastname") else { fatalError() }
        lastnameTextField.text = lastname
    }
    private func updateEmailTextField() {
        emailTextField = getTextField(with: "")
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(spacing)
        }
        guard let email = UserDefaults.standard.string(forKey: "email") else { fatalError() }
        emailTextField.text = email
    }
    private func updateDoneButton() {
        view.addSubview(doneButton)
        switch editableData {
        case "Bio":
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(bioTextView.snp.bottom).offset(spacing*2)
            }
        case "First Name":
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(firstnameTextField.snp.bottom).offset(spacing*2)
            }
        case "Last Name":
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(lastnameTextField.snp.bottom).offset(spacing*2)
            }
        case "Password":
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(passwordTextField3.snp.bottom).offset(spacing*2)
            }
        case "Email":
            doneButton.snp.makeConstraints { make in
                make.top.equalTo(emailTextField.snp.bottom).offset(spacing*2)
            }
        default:
            fatalError()
        }
        doneButton.backgroundColor = UIColor(hex: "#4fa1d6")
        doneButton.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.65)
        }
        doneButton.layer.cornerRadius = 20
        doneButton.setTitle("DONE", for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "Avenir Heavy", size: 20)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
}
//Extension for logic functions
extension ChangeAccountDataViewController {
    @objc private func didTapDoneButton() {
        startActivityIndicator()
        switch editableData {
        case "Bio":
            let bodyData = ["new_about" : bioTextView.text ?? ""]
            changeAccountDataViewModel.changeRequest(bodyData: bodyData, path: "user/profile/about")
        case "First Name":
            let bodyData = ["firstname" : firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""]
            changeAccountDataViewModel.changeRequest(bodyData: bodyData, path: "user/profile/firstname")
        case "Last Name":
            let bodyData = ["lastname" : lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""]
            changeAccountDataViewModel.changeRequest(bodyData: bodyData, path: "user/profile/lastname")
        case "Password":
            let bodyData = [
                "old_password" : passwordTextField1.text ?? "",
                "new_password1" : passwordTextField2.text ?? "",
                "new_password2" : passwordTextField3.text ?? ""
            ]
            changeAccountDataViewModel.changeRequest(bodyData: bodyData, path: "user/auth/update/password")
        case "Email":
            print("Not handled yet!")
        //            changeAccountDataViewModel.changeRequestProfile(with: "email", newData: emailTextField.text ?? "", endpoint: "")
        default:
            fatalError()
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
//Extension for view model delegate
extension ChangeAccountDataViewController: ChangeAccountDataViewModelDelegate {
    func goToSettingsPage() {
        switch editableData {
        case "Bio":
            UserDefaults.standard.setValue(bioTextView.text, forKey: "bio")
        case "First Name":
            UserDefaults.standard.setValue(firstnameTextField.text, forKey: "firstname")
        case "Last Name":
            UserDefaults.standard.setValue(lastnameTextField.text, forKey: "lastname")
        case "Email":
            UserDefaults.standard.setValue(emailTextField.text, forKey: "email")
        case "Password":
            print("Password has been changed successfully!")
        default:
            fatalError()
        }
        completion?()
        navigationController?.popViewController(animated: true)
    }
    
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
}

extension ChangeAccountDataViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let content = (safeAreaOriginY + CGFloat(spacing) + textView.bounds.height) + view.frame.origin.y
        if content > view.bounds.height - (keyboardHeight ?? 0) {
            view.frame.origin.y = view.frame.origin.y - (content - (view.bounds.height - (keyboardHeight ?? 0))) - 20
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !text.isEmpty && text.first!.isNewline { return false }
        return textView.text.count + text.count <= characterLimit
    }
}
