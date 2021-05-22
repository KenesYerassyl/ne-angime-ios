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
    func statusChange(text: String, hide: Bool)
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
        users.removeAll()
        UserManager.shared.getAllUsers { [weak self] (newUsers) in
            if let newUsers = newUsers {
                self?.users = newUsers
                DispatchQueue.main.async {
                    self?.delegate?.statusChange(text: "Sorry, you do not have friends yet.", hide: !newUsers.isEmpty)
                    self?.delegate?.userMayInteract()
                    self?.delegate?.reloadCollectionView()
                }
            } else {
                DispatchQueue.main.async {
                    self?.delegate?.statusChange(text: "Sorry, we could not load your friend list.", hide: false)
                    self?.delegate?.userMayInteract()
                    self?.delegate?.reloadCollectionView()
                }
                print("Unexpected error: new users fetched wrong")
            }
        }
    }
    
    func getUserImageURL(at index: Int) -> URL? {
        return URL(string: users[index].avatar ?? "")
    }
}
