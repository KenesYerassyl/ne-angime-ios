//
//  UserProfileViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/21/21.
//

import Foundation

protocol UserProfileViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
    var username: String { get set }
    func userMayInteract()
    func setUserProfile(fullName: String, avatar: URL?)
    func setStatus(_ newStatus: FriendStatus, refreshingList: Bool)
}

class UserProfileViewModel {
    
    var delegate: UserProfileViewModelDelegate?
    var user = User.undefined
    
    func fetchUserProfile() {
        user = User.undefined
        guard let username = delegate?.username else {
            print("Error: passed username is undefined.")
            DispatchQueue.main.async {
                self.delegate?.userMayInteract()
                self.delegate?.showErrorAlert(title: "Something went wrong.", message: "Please, try again later!")
            }
            return
        }
        UserManager.shared.getUser(username: username) { [weak self] user in
            if let user = user {
                self?.user = user
                DispatchQueue.main.async {
                    guard let status = user.status else { fatalError() }
                    self?.delegate?.setUserProfile(fullName: "\(user.firstname) \(user.lastname)", avatar: URL(string: user.avatar ?? ""))
                    self?.delegate?.setStatus(status, refreshingList: false)
                    self?.delegate?.userMayInteract()
                }
            } else {
                print("Error: user cannot be got.")
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.showErrorAlert(title: "Something went wrong.", message: "Please, try again later!")
                }
            }
        }
    }
    
    func changeRelation() {
        guard let status = user.status else { fatalError() }
        var method: HTTPMethod
        var path: String
        var newStatus: FriendStatus
        switch status {
        case .friend:
            method = .delete
            path = "friends/remove/\(user.userID)"
            newStatus = .incomingRequest
        case .incomingRequest:
            method = .post
            path = "friends/approve/\(user.userID)"
            newStatus = .friend
        case .outcomingRequest:
            method = .delete
            path = "friends/cancel_request/\(user.userID)"
            newStatus = .noRelation
        case .noRelation:
            method = .post
            path = "friends/request/\(user.userID)"
            newStatus = .outcomingRequest
        }
        let request = APIRequest(method: method, path: path)
        APIClient().request(request, isAccessTokenRequired: true) { [weak self] (data, response, error) in
            if let data = data, let response = response {
                if (200...299).contains(response.statusCode) {
                    self?.user.status = newStatus
                    DispatchQueue.main.async {
                        self?.delegate?.setStatus(newStatus, refreshingList: true)
                        self?.delegate?.userMayInteract()
                    }
                } else if response.statusCode == 401 {
                    APIClient().refresh { (result) in
                        if result == .success {
                            self?.changeRelation()
                        } else {
                            print("Error in refreshing token while uploading image")
                            DispatchQueue.main.async {
                                self?.delegate?.userMayInteract()
                                self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Please, try again later!")
                            }
                        }
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String : String], let message = json["message"] {
                        DispatchQueue.main.async {
                            self?.delegate?.userMayInteract()
                            self?.delegate?.showErrorAlert(title: "Something went wrong", message: message)
                        }
                    } else {
                        print("Unexpected error occured: failed to decode message.")
                        DispatchQueue.main.async {
                            self?.delegate?.userMayInteract()
                            self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Please, try again later!")
                        }
                    }
                }
            } else if let error = error {
                print("Error in uploading a profile image: \(error)")
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Please, try again later!")
                }
            } else {
                print("Unexpected error occured: data, response, and error are all nil.")
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.showErrorAlert(title: "Something went wrong", message: "Please, try again later!")
                }
            }
        }
    }
}
