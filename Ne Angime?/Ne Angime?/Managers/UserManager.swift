//
//  UserData.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

class UserManager {
    public static let shared = UserManager()
    private init(){}
    
    public func getUser(username: String, _ completion: @escaping(User?) -> Void) {
        guard let url = URL(string: "https://kenesyerassyl-kenesyerassyl-node-chat-app.zeet.app/api/users/user/\(username)"),
              let cookie = UserDefaults.standard.string(forKey: "token")
        else {
            completion(nil)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("token=\(cookie)", forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data, let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299 {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async { completion(user) }
                } catch {
                    print("Error in fetching a user: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else if let error = error {
                print("Error in fetching a user: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
    
    func getAllUsers(_ completion: @escaping([User]?, Error?) -> Void) {
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
                    DispatchQueue.main.async { completion(newUsers, nil) }
                } catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            } else if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        task.resume()
    }
}