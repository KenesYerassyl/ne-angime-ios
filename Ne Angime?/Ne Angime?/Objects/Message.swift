//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation

struct Message: Codable {
    var createdAt: Double
    var message: String
    var messageID: String
    var recipientUsername: String
    var senderUsername: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case message
        case messageID = "message_id"
        case recipientUsername = "recipient_username"
        case senderUsername = "sender_username"
    }
}
