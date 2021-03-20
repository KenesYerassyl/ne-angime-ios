//
//  ProfileViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/8/21.
//

import Foundation

protocol ProfileViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
}

class ProfileViewModel {
    
    weak var delegate: ProfileViewModelDelegate?
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "firstname")
        UserDefaults.standard.removeObject(forKey: "lastname")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "avatar")
        WebSocket.shared.disconnect()
        CoreDataManager.shared.deleteAllData()
    }
    
    func getUserFullName() -> (String, String) {
        guard let firstname = UserDefaults.standard.string(forKey: "firstname"),
              let lastname = UserDefaults.standard.string(forKey: "lastname") else { return ("undefined", "undefined") }
        return ("\(firstname)", "\(lastname)")
    }
    
    func uploadImage(imageData: String, _ completion: @escaping(Bool) -> Void) {
        guard let cookie = UserDefaults.standard.string(forKey: "token"),
              let data = try? JSONSerialization.data(withJSONObject: ["avatar" : imageData]) else {
            completion(false)
            return
        }
        var request = APIRequest(method: .post, path: "auth/update/avatar")
        request.headers = [
            HTTPHeader(field: "Cookie", value: "token=\(cookie)"),
            HTTPHeader(field: "Content-Type", value: "application/json")
        ]
        request.body = data
        APIClient().request(request) { (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String : Any],
                              let url = json["url"] as? String else { return }
                        UserDefaults.standard.set(url, forKey: "avatar")
                        DispatchQueue.main.async { completion(true) }
                    } catch {
                        print("Error in decoding data from uploading profile image: \(error)")
                        DispatchQueue.main.async { completion(false) }
                    }
                } else if response.statusCode == 413 {
                    DispatchQueue.main.async {
                        self.delegate?.showErrorAlert(title: "Something went wrong", message: "The size of an image should be less than 10 Mb. This image is too heavy, please choose another one.")
                        completion(false)
                    }
                } else {
                    print("Unexpected error occured: unhandled response status code.")
                    completion(false)
                }
            } else if let error = error {
                print("Error in uploading a profile image: \(error)")
                DispatchQueue.main.async { completion(false) }
            } else {
                print("Unexpected error occured: data, response, and error are all nil.")
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
}
