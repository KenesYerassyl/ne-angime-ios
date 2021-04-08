//
//  MessageRealm.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 4/6/21.
//

import RealmSwift
import Realm

class MessageRealm: Object {
    
    @objc dynamic var createdAt: Double = 0.0
    @objc dynamic var message: String = ""
    @objc dynamic var messageID: String = ""
    @objc dynamic var recipientUsername: String = ""
    @objc dynamic var senderUsername: String = ""
    @objc dynamic var isSeen: Bool = false
    
    convenience init(createdAt: Double, message: String, messageID: String, recipientUsername: String, senderUsername: String, isSeen: Bool) {
        self.init()
        self.createdAt = createdAt
        self.message = message
        self.messageID = messageID
        self.recipientUsername = recipientUsername
        self.senderUsername = senderUsername
        self.isSeen = isSeen
    }
    
    func toMessage() -> Message {
        let message = Message(
            createdAt: self.createdAt,
            message: self.message,
            messageID: self.messageID,
            recipientUsername: self.recipientUsername,
            senderUsername: self.senderUsername,
            isSeen: self.isSeen
        )
        return message
    }
    
    override static func primaryKey() -> String? {
        return "messageID"
    }
}
