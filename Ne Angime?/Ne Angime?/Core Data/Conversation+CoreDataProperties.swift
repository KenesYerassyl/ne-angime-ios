//
//  Conversation+CoreDataProperties.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//
//

import Foundation
import CoreData


extension Conversation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }

    @NSManaged public var conversationID: String?
    @NSManaged public var recipientUsername: String?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Conversation {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: MessageCoreData)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: MessageCoreData)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension Conversation : Identifiable {

}
