//
//  Conversation.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation


struct Conversation: Codable, Equatable {
    var conversationID: String
    var messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case messages
        case conversationID = "conversation_id"
    }
    
    static func == (left: Conversation, right: Conversation) -> Bool {
        if left.conversationID != right.conversationID { return false }
        if left.messages.count != right.messages.count { return false }
        for index in stride(from: 0, to: left.messages.count, by: 1) {
            if left.messages[index] != right.messages[index] { return false }
        }
        return true
    }
    
    static func != (left: Conversation, right: Conversation) -> Bool {
        if left.conversationID != right.conversationID { return true }
        if left.messages.count != right.messages.count { return true }
        for index in stride(from: 0, to: left.messages.count, by: 1) {
            if left.messages[index] != right.messages[index] { return true }
        }
        return false
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
