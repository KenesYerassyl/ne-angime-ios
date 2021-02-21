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
        
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/login"),
              let jsonData = try? JSONSerialization.data(withJSONObject: signInData) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(<#T##value: String##String#>, forHTTPHeaderField: <#T##String#>)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let response = response as? HTTPURLResponse,
               let url = response.url,
               let allHeadersField = response.allHeaderFields as? [String : String] {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if 200 <= response.statusCode && response.statusCode <= 299 {
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeadersField, for: url)
                            guard let userData = json["data"] as? [String : Any],
                                  let username = userData["username"],
                                  let firstname = userData["firstname"],
                                  let lastname = userData["lastname"],
                                  let email = userData["email"],
                                  let userID = userData["user_id"],
                                  let cookieValue = cookies.first?.value else { return }
                            UserDefaults.standard.set(username, forKey: "username")
                            UserDefaults.standard.set(firstname, forKey: "firstname")
                            UserDefaults.standard.set(lastname, forKey: "lastname")
                            UserDefaults.standard.set(email, forKey: "email")
                            UserDefaults.standard.set(cookieValue, forKey: "token")
                            UserDefaults.standard.set(userID, forKey: "userID")
                            DispatchQueue.main.async {
                                self.delegate?.userMayInteract()
                                self.delegate?.goToMainPage()
                            }
                        } else {
                            guard let message = json["message"] as? String else { return }
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
            self.delegate?.userMayInteract()
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
