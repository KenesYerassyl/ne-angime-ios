//
//  SignUpViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/14/21.
//

import Foundation

protocol SignUpViewModelDelegate1: class {
    func showErrorAlert(title: String, message: String)
    func goToNextStage(username: String, firstname: String, lastname: String)
}

class SignUpViewModel1 {    
    
    weak var delegate: SignUpViewModelDelegate1?
    
    func signUpStage1(username: String, firstname: String, lastname: String) {
        let signUpData1 = ["username" : username, "firstname" : firstname, "lastname" : lastname]
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/register?stage=1"),
              let jsonData = try? JSONSerialization.data(withJSONObject: signUpData1) else { return }
        
        var request = URLRequest(url: url)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse {
                if 200 <= response.statusCode && response.statusCode <= 299 {
                    DispatchQueue.main.async {
                        self.delegate?.goToNextStage(
                            username: username,
                            firstname: firstname,
                            lastname: lastname
                        )
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
            } else
            if let error = error {
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
