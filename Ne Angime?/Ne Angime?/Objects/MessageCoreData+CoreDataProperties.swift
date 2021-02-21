//
//  MessageCoreData+CoreDataProperties.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//
//

import Foundation
import CoreData


extension MessageCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageCoreData> {
        return NSFetchRequest<MessageCoreData>(entityName: "MessageCoreData")
    }

    @NSManaged public var isSenderMe: Bool
    @NSManaged public var message: String?
    @NSManaged public var messageID: String?
    @NSManaged public var createdAt: Double
    @NSManaged public var conversation: Conversation?

}

extension MessageCoreData : Identifiable {

}
