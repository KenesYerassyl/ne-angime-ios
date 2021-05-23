//
//  ProfileViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/8/21.
//

import Foundation

protocol ProfileViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
    func setImageWith(url: URL?)
    func userMayInteract()
}

class ProfileViewModel {

    weak var delegate: ProfileViewModelDelegate?
    
    func getUserFullName() -> (String, String) {
        guard let firstname = UserDefaults.standard.string(forKey: "firstname"),
              let lastname = UserDefaults.standard.string(forKey: "lastname") else { return ("undefined", "undefined") }
        return ("\(firstname)", "\(lastname)")
    }

    func uploadImage(imageData: String) {
        guard let data = try? JSONSerialization.data(withJSONObject: ["avatar" : imageData]) else {
            DispatchQueue.main.async { self.delegate?.userMayInteract() }
            print("Error in serializing JSON object while uploading image")
            return
        }
        var request = APIRequest(method: .post, path: "user/profile/avatar")
        request.body = data
        APIClient().request(request, isAccessTokenRequired: true) { (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String : Any],
                              let url = json["url"] as? String else { return }
                        UserDefaults.standard.set(url, forKey: "avatar")
                        DispatchQueue.main.async {
                            self.delegate?.setImageWith(url: URL(string: url))
                            self.delegate?.userMayInteract()
                        }
                    } catch {
                        DispatchQueue.main.async { self.delegate?.userMayInteract() }
                        print("Error in decoding data in uploading profile image: \(error)")
                    }
                } else if response.statusCode == 413 {
                    DispatchQueue.main.async {
                        self.delegate?.userMayInteract()
                        self.delegate?.showErrorAlert(title: "Something went wrong", message: "The size of an image should be less than 10 Mb. This image is too heavy, please choose another one.")
                    }
                } else if response.statusCode == 401 {
                    APIClient().refresh { (result) in
                        if result == .success {
                            self.uploadImage(imageData: imageData)
                        } else {
                            DispatchQueue.main.async { self.delegate?.userMayInteract() }
                            print("Error in refreshing token while uploading image")
                        }
                    }
                } else {
                    DispatchQueue.main.async { self.delegate?.userMayInteract() }
                    print("Unexpected error occured: unhandled response status code.")
                }
            } else if let error = error {
                DispatchQueue.main.async { self.delegate?.userMayInteract() }
                print("Error in uploading a profile image: \(error)")
            } else {
                DispatchQueue.main.async { self.delegate?.userMayInteract() }
                print("Unexpected error occured: data, response, and error are all nil.")
            }
        }
    }
}
