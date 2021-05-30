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
        var request = APIRequest(method: .post, path: "user/auth/login")
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
                   let refreshToken = userData["refresh_token"],
                   let isPrivate = userData["is_private"] {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(firstname, forKey: "firstname")
                    UserDefaults.standard.set(lastname, forKey: "lastname")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(user_id, forKey: "user_id")
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
                    UserDefaults.standard.set(isPrivate, forKey: "is_private")
                    if let avatar = userData["avatar"] {
                        UserDefaults.standard.set(avatar, forKey: "avatar")
                    }
                    if let bio = userData["about"] {
                        UserDefaults.standard.set(bio, forKey: "bio")
                    }
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToMainPage()
                    }
                } else if !((200...299).contains(response.statusCode)), let message = json["message"] as? String {
                    self?.signInError(message: message)
                } else {
                    print("Unexpected error occured: either status code is not in range 200...299 or JSON object has not property named 'message'.")
                    self?.signInError(message: "Unexpected error occured")
                }
            } else if let error = error {
                print("Error in signing in: \(error)")
                self?.signInError(message: error.localizedDescription)
            } else {
                print("Unexpected error occured: data, response, and error are all nil.")
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
