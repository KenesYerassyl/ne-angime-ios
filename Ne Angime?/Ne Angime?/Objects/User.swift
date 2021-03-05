//
//  User.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/15/21.
//

import Foundation

struct User: Codable, Equatable {
    var username: String
    var firstname: String
    var lastname: String
    var userID: String?
    var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case userID = "user_id"
        case avatar
    }
    
    init(username: String, firstname: String, lastname: String, userID: String?, avatar: String?) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.userID = userID
        self.avatar = avatar
    }
    
    static func == (left: User, right: User) -> Bool {
        return (left.username == right.username)
    }
}
