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
        status: .noRelation,
        bio: "",
        isPrivate: false
    )
    var username: String
    var firstname: String
    var lastname: String
    var avatar: String?
    var userID: Int?
    var status: FriendStatus?
    var bio: String?
    var isPrivate: Bool?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case avatar
        case userID = "user_id"
        case status
        case bio = "about"
        case isPrivate = "is_private"
    }
    
    static func == (left: User, right: User) -> Bool {
        return (left.username == right.username)
    }
}
