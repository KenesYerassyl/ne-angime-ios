//
//  MessageWebSocket.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

struct MessageWebSocket: Codable {
    var message: String
    var messageID: String
    var userID: String
    var createdAt: Double
    
    enum CodingKeys: String, CodingKey {
        case message
        case messageID = "message_id"
        case userID = "user_id"
        case createdAt = "created_at"
    }
}

enum EventType: String, Codable {
    case sendMessage = "send_message"
    case receiveMessage = "receive_message"
}

struct DataWebSocket: Codable {
    var type: EventType
    var username: String
    var message: MessageWebSocket
    
    enum CodingKeys: CodingKey {
        case type
        case username
        case message
    }
}
