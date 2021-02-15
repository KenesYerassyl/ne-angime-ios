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
    var email: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstname
        case lastname
        case email
    }
    
    init(username: String, firstname: String, lastname: String, email: String) {
        self.username = username
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
    }
}
