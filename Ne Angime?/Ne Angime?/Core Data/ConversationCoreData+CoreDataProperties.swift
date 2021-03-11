//
//  ConversationCoreData+CoreDataProperties.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/11/21.
//
//

import Foundation
import CoreData


extension ConversationCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConversationCoreData> {
        return NSFetchRequest<ConversationCoreData>(entityName: "ConversationCoreData")
    }

    @NSManaged public var conversationID: String?
    @NSManaged public var firstNameOfRecipient: String?
    @NSManaged public var lastNameOfRecipient: String?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension ConversationCoreData {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageCoreData)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageCoreData)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension ConversationCoreData : Identifiable {

}
