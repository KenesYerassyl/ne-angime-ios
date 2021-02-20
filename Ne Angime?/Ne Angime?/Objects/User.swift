//
//  User.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/15/21.
//

import Foundation

struct User: Codable {
    var username: String
    var firstname: String
    var lastname: String
    var email: String?
    var userID: Int
    var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case email
        case userID = "user_id"
        case avatar
    }
    
    init(username: String, firstname: String, lastname: String, email: String?, userID: Int, avatar: String?) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.userID = userID
        self.avatar = avatar
    }
}

extension User: Equatable {
    static func == (left: User, right: User) -> Bool {
        return (left.username == right.username)
    }
}
