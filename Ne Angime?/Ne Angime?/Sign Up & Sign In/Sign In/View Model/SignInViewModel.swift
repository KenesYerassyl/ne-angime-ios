//
//  SignUpViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol SignInViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
}

class SignInViewModel {
    
    weak var delegate: SignInViewModelDelegate?
    
    func signIn(username: String, password: String) {
        let logInData = ["username" : username, "password" : password]
        
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/login"),
              let jsonData = try? JSONSerialization.data(withJSONObject: logInData)
        else {
            print("NeAngime/Sign In & Sign Up/SignIn/View Model/SignInViewModel/21")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        guard let message = json["message"] as? String else { return }
                        if 200 <= response.statusCode && response.statusCode <= 299 {
                            guard let userData = json["data"] as? [String : String],
                                  let username = userData["username"],
                                  let firstname = userData["firstname"],
                                  let lastname = userData["lastname"],
                                  let email = userData["email"] else { return }
                            UserDefaults.standard.set("username", forKey: username)
                            UserDefaults.standard.set("firstname", forKey: firstname)
                            UserDefaults.standard.set("lastname", forKey: lastname)
                            UserDefaults.standard.set("email", forKey: email)
                        } else {
                            self.signInError(message: message)
                        }
                    }
                } catch {
                    self.signInError(message: error.localizedDescription)
                }
            } else
            if let error = error {
                self.signInError(message: error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func signInError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
