//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation
import CoreData

struct Message: Codable {
    var createdAt: Double
    var message: String
    var messageID: String
    var recipientUsername: String
    var senderUsername: String
    var isRead: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case message
        case messageID = "message_id"
        case recipientUsername = "recipient_username"
        case senderUsername = "sender_username"
    }
    
    func convertToMessageCoreData() -> MessageCoreData{
        let messageCoreData = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
        messageCoreData.createdAt = self.createdAt
        messageCoreData.isRead = self.isRead
        messageCoreData.message = self.message
        messageCoreData.messageID = self.messageID
        messageCoreData.recipientUsername = self.recipientUsername
        messageCoreData.senderUsername = self.senderUsername
        return messageCoreData
    }
}
