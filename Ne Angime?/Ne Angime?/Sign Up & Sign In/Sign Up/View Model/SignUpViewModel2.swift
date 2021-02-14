//
//  SignUpViewModel2.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/14/21.
//

import Foundation

class SignUpViewModel2 {
    
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
              let password2 = password2
        else {
            //TODO: show some error, i.g. not all fields are filled etc.
            return
        }
        let signUpData = [
            "firstname" : firstName,
            "lastname" : lastName,
            "username" : userName,
            "email" : email,
            "password1" : password1,
            "password2" : password2
        ]
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/register"),
              let jsonData = try? JSONSerialization.data(withJSONObject: signUpData)
        else {
            print("NeAngime/Sign In & Sign Up/Sign Up/View Model/SignUpViewModel2/41")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                //save data
                print(String(data: data, encoding: .utf8)!)
            } else if let error = error {
                //handle error
            }
        }
        task.resume()
    }
}
