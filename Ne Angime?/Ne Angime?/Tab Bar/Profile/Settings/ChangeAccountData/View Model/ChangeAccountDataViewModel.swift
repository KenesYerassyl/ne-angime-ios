//
//  ChangeAccountDataViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 6/3/21.
//

import Foundation

protocol ChangeAccountDataViewModelDelegate: class {
    func userMayInteract()
    func showErrorAlert(title: String, message: String)
    func goToSettingsPage()
}

class ChangeAccountDataViewModel {
    var delegate: ChangeAccountDataViewModelDelegate?
    
    func changeRequest(bodyData: [String : String], path: String) {
        var request = APIRequest(method: .put, path: path)
        guard let data = try? JSONSerialization.data(withJSONObject: bodyData) else {
            DispatchQueue.main.async {
                self.delegate?.userMayInteract()
                self.delegate?.showErrorAlert(title: "Something went wrong", message: "Unexpected error occured")
            }
            return
        }
        request.body = data
        APIClient().request(request, isAccessTokenRequired: true) { [weak self] (data, response, error) in
            if let data = data, let response = response,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any], let message = json["message"] as? String {
                if (200...299).contains(response.statusCode) {
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.goToSettingsPage()
                    }
                } else {
                    print("Unexpected error occured: either status code is not in range 200...299 or JSON object has not property named 'message'.")
                    DispatchQueue.main.async {
                        self?.delegate?.userMayInteract()
                        self?.delegate?.showErrorAlert(title: "Something went wrong", message: message)
                    }
                }
            } else if let error = error {
                print("Error in signing in: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Unexpected error occured")
                }
            } else {
                print("Unexpected error occured: data, response, and error are all nil.")
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Unexpected error occured")
                }
            }
        }
    }
}
