//
//  UserData.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

class UserManager {
    public static let shared = UserManager()
    private init() {}
    
    func getOtherUsername(from conversationID: String) -> String {
        var firstUsername = "", secondUsername = ""
        var isAmpercanMet1 = false
        var isAmpercanMet2 = false
        for item in conversationID {
            if item == "&" {
                if isAmpercanMet1 {
                    isAmpercanMet2 = true
                } else {
                    isAmpercanMet1 = true
                }
            } else {
                if isAmpercanMet2 {
                    secondUsername.append(item)
                } else {
                    firstUsername.append(item)
                }
            }
        }
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return "undefined" }
        return (firstUsername == currentUsername ? secondUsername : firstUsername)
    }
    
    func getUser(username: String, _ completion: @escaping(User?) -> Void) {
        let request = APIRequest(method: .get, path: "users/user/\(username)")
        
        APIClient().request(request, isAccessTokenRequired: true) { (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    do {
                        let userDict = try JSONDecoder().decode([String : User].self, from: data)
                        guard let user = userDict["user"] else {
                            completion(nil)
                            return
                        }
                        completion(user)
                    } catch {
                        print("Error in decoding a user: \(error)")
                        completion(nil)
                    }
                } else if response.statusCode == 401 {
                    APIClient().refresh { (result) in
                        if result == .success {
                            self.getUser(username: username) { user in completion(user) }
                        } else {
                            completion(nil)
                        }
                    }
                } else {
                    print("Unexpected error occured: unhandled response status code.")
                    completion(nil)
                }
            } else if let error = error {
                print("Error in fetching a user: \(error)")
                completion(nil)
            }
        }
    }
    
    func getAllUsers(_ completion: @escaping([User]?) -> Void) {
        let request = APIRequest(method: .get, path: "users/all")
        APIClient().request(request, isAccessTokenRequired: true) { (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    do {
                        let userArray = try JSONDecoder().decode([String : [User]].self, from: data)
                        if let newUsers = userArray["users"] {
                            completion(newUsers)
                        } else {
                            completion(nil)
                        }
                    } catch {
                        print("Error in decoding [User] data: \(error)")
                        completion(nil)
                    }
                } else if response.statusCode == 401 {
                    APIClient().refresh { result in
                        if result == .success {
                            self.getAllUsers { users in completion(users) }
                        } else {
                            print("Failed to refresh token in getting all users.")
                            completion(nil)
                        }
                    }
                } else {
                    print("Unexpected error occured in requesting for all users: unhandled response status code \(response.statusCode).")
                    completion(nil)
                }
            } else if let error = error {
                print("Error in getting all users: \(error)")
                completion(nil)
            }
        }
    }
}
