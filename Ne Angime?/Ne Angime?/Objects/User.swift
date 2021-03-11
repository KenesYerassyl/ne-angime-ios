//
//  User.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/15/21.
//

import Foundation

struct User: Codable, Equatable {
    public static let undefined = User(username: "undefined", firstname: "undefined", lastname: "undefined", avatar: nil)
    var username: String
    var firstname: String
    var lastname: String
    var avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case avatar
    }
    
    init(username: String, firstname: String, lastname: String, avatar: String?) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.avatar = avatar
    }
    
    static func == (left: User, right: User) -> Bool {
        return (left.username == right.username)
    }
}
