//
//  FriendsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol FriendsViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
    func updateCollectionView()
}

class FriendsViewModel {
    weak var delegate: FriendsViewModelDelegate?
    
    var users = [User]()
    
    func getNumberOfItems() -> Int {
        return users.count
    }
    func getUser(at index: Int) -> String {
        return "hello"
    }
    func fetchAllUsers() {
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/users/all"),
              let cookie = UserDefaults.standard.string(forKey: "token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token=\(cookie)", forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299 {
                do {
                    let userArray = try JSONDecoder().decode([String : [User]].self, from: data)
                    guard let newUsers = userArray["users"] else { return }
                    self.users = newUsers
                    DispatchQueue.main.async {
                        self.delegate?.updateCollectionView()
                    }
                } catch {
                    self.friendsError(message: error.localizedDescription)
                }
            } else if let error = error {
                self.friendsError(message: error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func friendsError(message: String) {
        DispatchQueue.main.async {
            self.delegate?.showErrorAlert(
                title: "Something went wrong",
                message: message
            )
        }
    }
}
