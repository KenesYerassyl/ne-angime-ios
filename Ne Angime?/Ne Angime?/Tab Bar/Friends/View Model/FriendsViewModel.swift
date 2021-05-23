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
    func statusChange(text: String, isTextChanged: Bool)
}

class FriendsViewModel {
    weak var delegate: FriendsViewModelDelegate?
    
    var users = [[User]](repeating: [User](), count: 3)
    
    func getNumberOfItems(at segment: Int) -> Int {
        return users[segment].count
    }
    func getUser(at segment: Int, at index: Int) -> User {
        return users[segment][index]
    }
    
    func fetchAllRelatedUsers() {
        users = [[User]](repeating: [User](), count: 3)
        UserManager.shared.getAllRelatedUsers { [weak self] (relatedUsers) in
            var isSuccess: Bool
            if let relatedUsers = relatedUsers {
                self?.users = relatedUsers
                isSuccess = true
            } else {
                isSuccess = false
                print("Unexpected error: related users fetched wrong")
            }
            DispatchQueue.main.async {
                self?.delegate?.statusChange(text: isSuccess ? "Sorry, this list is empty." : "Sorry, we could not load your this list.", isTextChanged: true)
                self?.delegate?.userMayInteract()
                self?.delegate?.reloadCollectionView()
            }
        }
    }
    
    func getUserImageURL(at segment: Int, at index: Int) -> URL? {
        return URL(string: users[segment][index].avatar ?? "")
    }
}
