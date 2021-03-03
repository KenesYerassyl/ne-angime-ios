//
//  MessageWebSocket.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation


enum EventType: String, Codable {
    case sendMessage = "send_message"
    case receiveMessage = "receive_message"
}

struct MessageWebSocket: Codable {
    var type: EventType
    var message: String
    var messageID: String
    var conversationID: String
    var senderUsername: String
    var recipientUsername: String
    var createdAt: Double
    
    enum CodingKeys: String, CodingKey {
        case type
        case message
        case messageID = "message_id"
        case conversationID = "conversation_id"
        case senderUsername = "sender_username"
        case recipientUsername = "recipient_username"
        case createdAt = "created_at"
    }
}
