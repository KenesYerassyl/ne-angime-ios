//
//  MessageCoreData+CoreDataClass.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/3/21.
//
//

import Foundation
import CoreData


public class MessageCoreData: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case message
        case messageID = "message_id"
        case senderUsername = "sender_username"
        case recipientUsername = "recipient_username"
    }
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        self.messageID = try container.decode(String.self, forKey: .messageID)
        self.createdAt = try container.decode(Double.self, forKey: .createdAt)
        self.senderUsername = try container.decode(String.self, forKey: .senderUsername)
        self.recipientUsername = try container.decode(String.self, forKey: .recipientUsername)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(message, forKey: .message)
            try container.encode(messageID, forKey: .messageID)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(senderUsername, forKey: .senderUsername)
            try container.encode(recipientUsername, forKey: .recipientUsername)
        } catch {
            print("Error in encoding MessageCoreData: \(error)")
        }
    }
}
