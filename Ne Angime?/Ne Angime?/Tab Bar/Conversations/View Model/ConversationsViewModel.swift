//
//  ConversationsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

class ConversationsViewModel {
    let users = ["Barat Nurbolat",
                 "Turan Sultan",
                 "Makhmud Bedel"
    ]
    
    let messages = [ "Ok, those tits were great. Ok, those tits were great. Ok, those tits were great.",
                     "Hello",
                     "That one was good, can we fuck each other next time?"
    ]
    
    func getNumberOfItems() -> Int {
        return users.count
    }
    func getUser(at index: Int) -> String {
        return users[index]
    }
    func getMessage(at index: Int) -> String {
        return messages[index]
    }
}
