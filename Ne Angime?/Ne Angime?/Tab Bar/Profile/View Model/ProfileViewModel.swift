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
        WebSocket.shared.disconnect()
        CoreDataManager.shared.deleteAllData()
    }
    
    func getUserFullName() -> (String, String) {
        guard let firstname = UserDefaults.standard.string(forKey: "firstname"),
              let lastname = UserDefaults.standard.string(forKey: "lastname") else { return ("undefined", "undefined") }
        return ("\(firstname)", "\(lastname)")
    }
    
    func uploadImage(imageData: String, _ completion: @escaping(Bool) -> Void) {
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/auth/update/avatar"),
              let cookie = UserDefaults.standard.string(forKey: "token")
        else {
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("token=\(cookie)", forHTTPHeaderField: "Cookie")
        do {
            let data = try JSONSerialization.data(withJSONObject: ["avatar" : imageData])
            request.httpBody = data
        } catch {
            completion(false)
            print("Error in decoding image data: \(error)")
        }
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, let data = data {
                if 200 <= httpResponse.statusCode && httpResponse.statusCode <= 299 {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String : Any],
                              let url = json["url"] as? String else { return }
                        UserDefaults.standard.set(url, forKey: "avatar")
                        DispatchQueue.main.async { completion(true) }
                    } catch {
                        DispatchQueue.main.async { completion(false) }
                        print("Error in decoding data from uploading profile image: \(error)")
                    }
                } else if httpResponse.statusCode == 413 {
                    DispatchQueue.main.async {
                        self.delegate?.showErrorAlert(title: "Something went wrong", message: "The size of an image should be less than 10 Mb. This image is too heavy, please choose another one.")
                        completion(false)
                    }
                } else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        self.delegate?.showErrorAlert(title: "Something went wrong", message: "It seems that you did not select an image.")
                        completion(false)
                    }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            } else if let error = error {
                DispatchQueue.main.async { completion(false) }
                print("Error in uploading a profile image: \(error)")
            }
        }.resume()
    }
}
