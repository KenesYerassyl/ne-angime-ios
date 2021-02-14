//
//  SignUpViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol SignInViewModelDelegate: class {

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
            if let data = data {
                //TODO: save data
            } else if let error = error {
                //TODO: handle error
            }
        }
        task.resume()
    }
}
