//
//  User.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/15/21.
//

import Foundation

enum FriendStatus: String, Codable {
    case friend = "friend"
    case incomingRequest = "incoming_request"
    case outcomingRequest = "outcoming_request"
    case noRelation = "no_relation"
}

struct User: Codable, Equatable {
    public static let undefined = User(
        username: "undefined",
        firstname: "undefined",
        lastname: "undefined",
        avatar: nil,
        userID: -1,
        status: .noRelation
    )
    var username: String
    var firstname: String
    var lastname: String
    var avatar: String?
    var userID: Int
    var status: FriendStatus?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case avatar
        case userID = "user_id"
        case status
    }
    
    init(username: String, firstname: String, lastname: String, avatar: String?, userID: Int, status: FriendStatus?) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.avatar = avatar
        self.userID = userID
        self.status = status
    }
    
    static func == (left: User, right: User) -> Bool {
        return (left.username == right.username)
    }
}
