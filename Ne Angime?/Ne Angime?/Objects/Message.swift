//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation
import CoreData

struct Message: Codable, Equatable {
    var createdAt: Double
    var message: String
    var messageID: String
    var recipientUsername: String
    var senderUsername: String
    var isSeen: Bool
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case message
        case messageID = "message_id"
        case recipientUsername = "recipient_username"
        case senderUsername = "sender_username"
        case isSeen = "is_seen"
    }
    
    func convertToMessageCoreData() -> MessageCoreData{
        let messageCoreData = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
        messageCoreData.createdAt = self.createdAt
        messageCoreData.isSeen = self.isSeen
        messageCoreData.message = self.message
        messageCoreData.messageID = self.messageID
        messageCoreData.recipientUsername = self.recipientUsername
        messageCoreData.senderUsername = self.senderUsername
        return messageCoreData
    }
    
    static func == (left: Message, right: Message) -> Bool {
        if left.messageID != right.messageID { return false }
        if left.message != right.message { return false }
        if left.isSeen != right.isSeen { return false }
        if left.recipientUsername != right.recipientUsername { return false }
        if left.senderUsername != right.senderUsername { return false }
        if left.createdAt != right.createdAt { return false }
        return true
    }
    
    static func != (left: Message, right: Message) -> Bool {
        if left.messageID != right.messageID { return true }
        if left.message != right.message { return true }
        if left.isSeen != right.isSeen { return true }
        if left.recipientUsername != right.recipientUsername { return true }
        if left.senderUsername != right.senderUsername { return true }
        if left.createdAt != right.createdAt { return true }
        return false
    }
}
