//
//  SignUpViewController1.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/14/21.
//

import UIKit

class SignUpViewController1: UIViewController {
    
    private let spacing = 24.0
    private var fieldsView = UIView()
    private var welcomeLabel = UILabel()
    private var firstNameTextField = UITextField()
    private var lastNameTextField = UITextField()
    private var userNameTextField = UITextField()
    private var nextButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#30289f")
        updateFieldsView()
        updateWelcomeLabel()
        updateFirstNameTextField()
        updateLastNameTextField()
        updateUserNameTextField()
        updateNextButton()
    }
    
    func updateFieldsView() {
        view.addSubview(fieldsView)
        fieldsView.backgroundColor = .white
        fieldsView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.7)
            make.bottom.equalTo(view)
        }
        fieldsView.layer.cornerRadius = 30
    }
    
    func updateWelcomeLabel() {
        view.addSubview(welcomeLabel)
        welcomeLabel.font = UIFont(name: "Avenir Black", size: 24)
        welcomeLabel.text = "Thank you for joining us!"
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(view.bounds.height * 0.05)
            make.top.equalTo(fieldsView).offset(spacing)
        }
    }
    
    func updateFirstNameTextField() {
        view.addSubview(firstNameTextField)
        firstNameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(welcomeLabel.snp.bottom).offset(spacing*2)
        }
        firstNameTextField.layer.cornerRadius = 20
        firstNameTextField.layer.borderWidth = 3
        firstNameTextField.layer.borderColor = UIColor.systemGray5.cgColor
        firstNameTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        firstNameTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        firstNameTextField.font = UIFont(name: "Avenir", size: 20)
        firstNameTextField.placeholder = "Insert your First Name"
    }
    
    func updateLastNameTextField() {
        view.addSubview(lastNameTextField)
        lastNameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(firstNameTextField.snp.bottom).offset(spacing)
        }
        lastNameTextField.layer.cornerRadius = 20
        lastNameTextField.layer.borderWidth = 3
        lastNameTextField.layer.borderColor = UIColor.systemGray5.cgColor
        lastNameTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        lastNameTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        lastNameTextField.font = UIFont(name: "Avenir", size: 20)
        lastNameTextField.placeholder = "Insert your Last Name"
    }
    
    func updateUserNameTextField() {
        view.addSubview(userNameTextField)
        userNameTextField.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.85)
            make.top.equalTo(lastNameTextField.snp.bottom).offset(spacing)
        }
        userNameTextField.layer.cornerRadius = 20
        userNameTextField.layer.borderWidth = 3
        userNameTextField.layer.borderColor = UIColor.systemGray5.cgColor
        userNameTextField.setRightPaddingPoints(view.bounds.width * 0.08)
        userNameTextField.setLeftPaddingPoints(view.bounds.width * 0.08)
        userNameTextField.font = UIFont(name: "Avenir", size: 20)
        userNameTextField.placeholder = "Insert the username"
    }
    
    func updateNextButton() {
        view.addSubview(nextButton)
        nextButton.backgroundColor = UIColor(hex: "#4fa1d6")
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(view.bounds.height * 0.09)
            make.centerX.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.65)
            make.top.equalTo(userNameTextField.snp.bottom).offset(spacing * 2)
        }
        nextButton.layer.cornerRadius = 20
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Avenir Heavy", size: 20)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
    }
}

extension SignUpViewController1 {
    @objc func didTapNextButton() {
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            //TODO: show some error: i.g fields are not correct or not filled
            return
        }
        navigationController?.pushViewController(SignUpViewController2(
                                                    firstName: firstName,
                                                    lastName: lastName,
                                                    userName: userName),
                                                    animated: true)
    }
}
