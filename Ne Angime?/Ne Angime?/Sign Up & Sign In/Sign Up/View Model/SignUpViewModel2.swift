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
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/register?stage=2"),
              let jsonData = try? JSONSerialization.data(withJSONObject: signUpData) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let response = response as? HTTPURLResponse,
               let url = response.url,
               let allHeaders = response.allHeaderFields as? [String : String] {
                if 200 <= response.statusCode && response.statusCode <= 299 {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaders, for: url)
                    guard let cookieValue = cookies.first?.value else { return }
                    UserDefaults.standard.set(userName, forKey: "username")
                    UserDefaults.standard.set(firstName, forKey: "firstname")
                    UserDefaults.standard.set(lastName, forKey: "lastname")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(cookieValue, forKey: "token")
                    
                    DispatchQueue.main.async {
                        self.delegate?.goToMainPage()
                    }
                } else {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String : String],
                              let message = json["message"] else { return }
                        self.signUpError(message: message)
                    } catch {
                        self.signUpError(message: error.localizedDescription)
                    }
                }
            } else if let error = error {
                self.signUpError(message: error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func signUpError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
