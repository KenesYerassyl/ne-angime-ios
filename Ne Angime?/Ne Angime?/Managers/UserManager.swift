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
        guard let cookie = UserDefaults.standard.string(forKey: "token") else {
            completion(nil)
            return
        }
        var request = APIRequest(method: .get, path: "users/user/\(username)")
        request.headers = [HTTPHeader(field: "Cookie", value: "token=\(cookie)")]
        
        APIClient().request(request) { (data, response, error) in
            if let data = data, let response = response, (200...299).contains(response.statusCode) {
                do {
                    let userDict = try JSONDecoder().decode([String : User].self, from: data)
                    guard let user = userDict["user"] else {
                        DispatchQueue.main.async { completion(nil) }
                        return
                    }
                    DispatchQueue.main.async { completion(user) }
                } catch {
                    print("Error in decoding a user: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else if let error = error {
                print("Error in fetching a user: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    func getImageOfUser(with username: String, avatar: String?, _ completion: @escaping(Data?) -> Void) {
        if CoreDataManager.shared.doesCachedImageExist("profile_image_\(username)") {
            CoreDataManager.shared.getCachedImage(imageID: "profile_image_\(username)") {  (cachedImage, error) in
                if let cachedImage = cachedImage, let data = cachedImage.imageData {
                    completion(data)
                } else if let error = error {
                    print("Error in getting cached image: \(error)")
                    completion(nil)
                }
            }
        } else {
            var userAvatar = ""
            let group = DispatchGroup()
            if let avatar = avatar {
                userAvatar = avatar
            } else {
                group.enter()
                UserManager.shared.getUser(username: username) { (user) in
                    guard let user = user, let avatar = user.avatar else {
                        completion(nil)
                        return
                    }
                    userAvatar = avatar
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                guard let url = URL(string: userAvatar), !userAvatar.isEmpty else {
                    completion(nil)
                    return
                }
                APIClient().request(url) { (data, response, error) in
                    if let data = data {
                        let cachedImage = CachedImage(entity: CachedImage.entity(), insertInto: CoreDataManager.shared.context)
                        cachedImage.imageID = "profile_image_\(username)"
                        cachedImage.imageData = data
                        CoreDataManager.shared.saveContext()
                        completion(data)
                    } else if let error = error {
                        completion(nil)
                        print("Error in downloading user's image: \(error)")
                    }
                }
            }
        }
    }
    
    func getAllUsers(_ completion: @escaping([User]?) -> Void) {
        guard let cookie = UserDefaults.standard.string(forKey: "token") else {
            completion(nil)
            return
        }
        var request = APIRequest(method: .get, path: "users/all")
        request.headers = [HTTPHeader(field: "Cookie", value: "token=\(cookie)")]
        
        APIClient().request(request) { (data, response, error) in
            if let data = data, let response = response, (200...299).contains(response.statusCode) {
                do {
                    let userArray = try JSONDecoder().decode([String : [User]].self, from: data)
                    if let newUsers = userArray["users"] {
                        DispatchQueue.main.async { completion(newUsers) }
                    } else {
                        DispatchQueue.main.async { completion(nil) }
                    }
                } catch {
                    print("Error in decoding [User] data: \(error)")
                    DispatchQueue.main.async { completion(nil) }
                }
            } else if let error = error {
                print("Error in getting all users: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
