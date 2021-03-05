//
//  Conversation+CoreDataClass.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/3/21.
//
//

import Foundation
import CoreData


public class Conversation: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case conversationID = "conversation_id"
        case messages
    }
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.conversationID = try container.decode(String.self, forKey: .conversationID)
        self.messages = try container.decode(Set<MessageCoreData>.self, forKey: .messages) as NSSet
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(conversationID, forKey: .conversationID)
            try container.encode(messages as? Set<MessageCoreData>, forKey: .messages)
        } catch {
            print("Error in encoding MessageCoreData: \(error)")
        }
    }
}
