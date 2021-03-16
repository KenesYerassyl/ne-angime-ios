//
//  MessageCoreData+CoreDataProperties.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/16/21.
//
//

import Foundation
import CoreData


extension MessageCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageCoreData> {
        return NSFetchRequest<MessageCoreData>(entityName: "MessageCoreData")
    }

    @NSManaged public var createdAt: Double
    @NSManaged public var isRead: Bool
    @NSManaged public var message: String?
    @NSManaged public var messageID: String?
    @NSManaged public var recipientUsername: String?
    @NSManaged public var senderUsername: String?
    @NSManaged public var conversation: ConversationCoreData?

}

extension MessageCoreData : Identifiable {

}
