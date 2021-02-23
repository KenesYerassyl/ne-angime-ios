//
//  FriendsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol FriendsViewModelDelegate: class {
    func updateCollectionView()
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
        UserManager.shared.getAllUsers { (newUsers, error) in
            if let newUsers = newUsers {
                self.users = newUsers
                DispatchQueue.main.async {
                    self.delegate?.userMayInteract()
                    self.delegate?.updateCollectionView()
                }
            } else if let error = error {
                print("Erro in fetching all users: \(error)")
            }
        }
    }
}
