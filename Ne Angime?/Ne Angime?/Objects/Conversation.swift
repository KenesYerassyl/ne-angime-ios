//
//  Conversation.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation

struct Conversation: Codable {
    var conversationID: String
    var messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case messages
        case conversationID = "conversation_id"
    }
    
    static func == (left: Conversation, right: Conversation) -> Bool {
        return (left.conversationID == right.conversationID)
    }
    
    static func < (left: Conversation, right: Conversation) -> Bool {
        guard let message1 = left.messages.last, let message2 = right.messages.last
        else {
            fatalError("Hoes be maad!")
        }
        return message1.createdAt < message2.createdAt
    }
    
    static func > (left: Conversation, right: Conversation) -> Bool {
        guard let message1 = left.messages.last, let message2 = right.messages.last
        else {
            fatalError("Hoes be maad!")
        }
        return message1.createdAt > message2.createdAt
    }
}
