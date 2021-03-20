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
    func userMayInteract()
}

class SignUpViewModel1 {    
    
    weak var delegate: SignUpViewModelDelegate1?
    
    func signUpStage1(username: String, firstname: String, lastname: String) {
        let signUpData1 = ["username" : username, "firstname" : firstname, "lastname" : lastname]
        guard let data = try? JSONSerialization.data(withJSONObject: signUpData1) else { return }
        var request = APIRequest(method: .post, path: "auth/register?stage=1")
        request.headers = [HTTPHeader(field: "Content-Type", value: "application/json")]
        request.body = data
        
        APIClient().request(request) { [weak self] (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToNextStage(
                            username: username,
                            firstname: firstname,
                            lastname: lastname
                        )
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String : String], let message = json["message"] {
                        self?.signUpError(message: message)
                    } else {
                        print("Unexpected error occured: response is not in range 200...299, also we either cannot serialize a JSON object or cannot find 'message' property inside JSON object.")
                        self?.signUpError(message: "Unexpected error occured")
                    }
                }
                
            } else if let error = error {
                print("Error in signing up stage 1: \(error)")
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
