//
//  FindViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/20/21.
//

import Foundation

protocol FindViewModelDelegate: class {
    func reloadCollectionView()
    func userMayInteract()
    func noResultsFound()
}

class FindViewModel {
    weak var delegate: FindViewModelDelegate?
    
    var users = [User]()
    
    func getNumberOfItems() -> Int {
        return users.count
    }
    func getUser(at index: Int) -> User {
        return users[index]
    }
    
    func fetchUsers(with query: String) {
        users.removeAll()
        let group = DispatchGroup()
        var tempUsers = [User]()
        group.enter()
        UserManager.shared.getAllUsers { (newUsers) in
            if let newUsers = newUsers {
                tempUsers = newUsers
            } else {
                print("Unexpected error: new users fetched wrong")
            }
            group.leave()
        }
        group.notify(queue: .main) {
            for user in tempUsers {
                if "\(user.firstname) \(user.lastname)".lowercased().hasPrefix(query) {
                    self.users.append(user)
                }
            }
            self.users.sort { (user1, user2) -> Bool in
                return "\(user1.firstname) \(user1.lastname)" < "\(user2.firstname) \(user2.lastname)"
            }
            DispatchQueue.main.async {
                self.delegate?.userMayInteract()
                self.delegate?.reloadCollectionView()
                if self.users.isEmpty {
                    self.delegate?.noResultsFound()
                }
            }
        }
    }
    
    func getUserImageURL(at index: Int) -> URL? {
        return URL(string: users[index].avatar ?? "")
    }
}
