//
//  ConversationRealm.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 4/6/21.
//

import RealmSwift

class ConversationRealm: Object {
    @objc dynamic var conversationID: String = ""
    @objc dynamic var firstNameOfRecipient: String = ""
    @objc dynamic var lastNameOfRecipient: String = ""
    let messages = List<MessageRealm>()
    
    convenience init(conversationID: String, firstNameOfRecipient: String, lastNameOfRecipient: String) {
        self.init()
        self.conversationID = conversationID
        self.firstNameOfRecipient = firstNameOfRecipient
        self.lastNameOfRecipient = lastNameOfRecipient
    }
    
    func toConversation() -> Conversation {
        var conversation = Conversation(conversationID: self.conversationID, messages: [])
        for message in self.messages {
            conversation.messages.append(message.toMessage())
        }
        return conversation
    }
    
    override static func primaryKey() -> String? {
        return "conversationID"
    }
}
