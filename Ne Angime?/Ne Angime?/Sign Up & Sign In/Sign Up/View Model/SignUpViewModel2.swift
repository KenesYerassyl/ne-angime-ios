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
        var request = APIRequest(method: .post, path: "user/auth/register?stage=2")
        request.body = data
        
        APIClient().request(request, isAccessTokenRequired: false) { [weak self] (data, response, error) in
            if let data = data, let response = response,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                if (200...299).contains(response.statusCode),
                   let userData = json["data"] as? [String : Any],
                   let username = userData["username"],
                   let firstname = userData["firstname"],
                   let lastname = userData["lastname"],
                   let email = userData["email"],
                   let user_id = userData["user_id"] as? Int,
                   let accessToken = userData["access_token"],
                   let refreshToken = userData["refresh_token"] {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(firstname, forKey: "firstname")
                    UserDefaults.standard.set(lastname, forKey: "lastname")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(user_id, forKey: "user_id")
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToMainPage()
                    }
                } else if !((200...299).contains(response.statusCode)), let message = json["message"] as? String {
                    self?.signUpError(message: message)
                } else {
                    print("Unexpected error occured: either status code is not in range 200...299 or JSON object has not property named 'message'.")
                    self?.signUpError(message: "Unexpected error occured")
                }
            } else if let error = error {
                print("Error in signing in: \(error)")
                self?.signUpError(message: error.localizedDescription)
            } else {
                print("Unexpected error occured: data, response, and error are all nil.")
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
