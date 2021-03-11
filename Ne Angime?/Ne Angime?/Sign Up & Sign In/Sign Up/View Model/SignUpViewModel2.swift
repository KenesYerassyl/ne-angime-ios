//
//  SignUpViewModel2.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/14/21.
//

import Foundation

protocol SignUpViewModelDelegate2: class {
    func showErrorAlert(title: String, message: String)
    func goToMainPage()
    func userMayInteract()
}

class SignUpViewModel2 {
    weak var delegate: SignUpViewModelDelegate2?
    var firstName: String?
    var lastName: String?
    var userName: String?
    var email: String?
    var password1: String?
    var password2: String?
    
    func signUp() {
        guard let firstName = firstName,
              let lastName = lastName,
              let userName = userName,
              let email = email,
              let password1 = password1,
              let password2 = password2 else { return }
        let signUpData = [
            "firstname" : firstName,
            "lastname" : lastName,
            "username" : userName,
            "email" : email,
            "password1" : password1,
            "password2" : password2
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: signUpData) else {
            signUpError(message: "Unexpected error occured")
            return
        }
        var request = APIRequest(method: .post, path: "auth/register?stage=2")
        request.headers = [HTTPHeader(field: "Content-Type", value: "application/json")]
        request.body = data
        
        APIClient().request(request) { [weak self] (data, response, error) in
            if let data = data, let response = response,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                if let url = response.url,
                   let allHeadersField = response.allHeaderFields as? [String : String],
                   (200...299).contains(response.statusCode),
                   let cookieValue = (HTTPCookie.cookies(withResponseHeaderFields: allHeadersField, for: url)).first?.value,
                   let userData = json["data"] as? [String : Any],
                   let username = userData["username"],
                   let firstname = userData["firstname"],
                   let lastname = userData["lastname"],
                   let email = userData["email"] {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(firstname, forKey: "firstname")
                    UserDefaults.standard.set(lastname, forKey: "lastname")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(cookieValue, forKey: "token")
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToMainPage()
                    }
                } else if !((200...299).contains(response.statusCode)), let message = json["message"] as? String {
                    self?.signUpError(message: message)
                }
            } else if let error = error {
                print("Error in signing in: \(error)")
                self?.signUpError(message: error.localizedDescription)
            } else {
                self?.signUpError(message: "Unexpected error occured")
            }
        }
    }
    
    func signUpError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.userMayInteract()
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
