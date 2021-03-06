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
}
