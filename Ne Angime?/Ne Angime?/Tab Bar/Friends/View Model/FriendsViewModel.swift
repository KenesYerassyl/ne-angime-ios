//
//  FriendsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol FriendsViewModelDelegate: class {
    func reloadCollectionView()
    func userMayInteract()
}

class FriendsViewModel {
    weak var delegate: FriendsViewModelDelegate?
    
    var users = [User]()
    
    func getNumberOfItems() -> Int {
        return users.count
    }
    func getUser(at index: Int) -> User {
        return users[index]
    }
    
    func fetchAllUsers() {
        UserManager.shared.getAllUsers { [weak self] (newUsers) in
            if let newUsers = newUsers {
                self?.users = newUsers
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.reloadCollectionView()
                }
            } else {
                print("Unexpected error: new users fetched wrong")
            }
        }
    }
    
    func getUserImageURL(at index: Int) -> URL? {
        return URL(string: users[index].avatar ?? "")
    }
}
