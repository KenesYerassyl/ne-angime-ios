//
//  UsersViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/23/21.
//

import Foundation

protocol UsersViewModelDelegate: class {
    func reloadCollectionView()
    func userMayInteract()
}

class UsersViewModel {
    weak var delegate: UsersViewModelDelegate?
    
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
