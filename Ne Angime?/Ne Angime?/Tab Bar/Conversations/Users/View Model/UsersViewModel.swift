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
        UserManager.shared.getAllRelatedUsers { [weak self] (relatedUsers) in
            if let relatedUsers = relatedUsers {
                self?.users = relatedUsers[0]
                DispatchQueue.main.async {
                    self?.delegate?.userMayInteract()
                    self?.delegate?.reloadCollectionView()
                }
            } else {
                print("Unexpected error: relagted users fetched wrong")
            }
        }
    }
    
    func getUserImageURL(at index: Int) -> URL? {
        return URL(string: users[index].avatar ?? "")
    }
}
