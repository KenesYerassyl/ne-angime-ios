//
//  FriendsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

class FriendsViewModel {
    let users = ["Barat Nurbolat",
                 "Alseitov Kazybek"
    ]

    func getNumberOfItems() -> Int {
        return users.count
    }
    func getUser(at index: Int) -> String {
        return users[index]
    }
}
