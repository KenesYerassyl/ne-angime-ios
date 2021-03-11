//
//  SignUpViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol SignInViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
    func goToMainPage()
    func userMayInteract()
}

class SignInViewModel {
    
    weak var delegate: SignInViewModelDelegate?
    
    func signIn(username: String, password: String) {
        let signInData = ["username" : username, "password" : password]
        guard let data = try? JSONSerialization.data(withJSONObject: signInData) else {
            signInError(message: "Unexpected error occured")
            return
        }
        var request = APIRequest(method: .post, path: "auth/login")
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
                    if let avatar = userData["avatar"] {
                        UserDefaults.standard.set(avatar, forKey: "avatar")
                    }
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToMainPage()
                    }
                } else if !((200...299).contains(response.statusCode)), let message = json["message"] as? String {
                    self?.signInError(message: message)
                }
            } else if let error = error {
                print("Error in signing in: \(error)")
                self?.signInError(message: error.localizedDescription)
            } else {
                self?.signInError(message: "Unexpected error occured")
            }
        }
    }
    
    func signInError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.userMayInteract()
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
