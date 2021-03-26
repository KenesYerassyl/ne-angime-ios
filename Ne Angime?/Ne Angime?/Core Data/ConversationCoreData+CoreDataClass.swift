//
//  ConversationCoreData+CoreDataClass.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/20/21.
//
//

import Foundation
import CoreData


public class ConversationCoreData: NSManagedObject {
    func convertToConversation() -> Conversation {
        var conversation = Conversation(
            conversationID: self.conversationID ?? "undefined",
            messages: []
        )
        guard let messages = self.messages as? Set<MessageCoreData> else { return conversation }
        for messageCoreData in messages {
            let message = Message(
                createdAt: messageCoreData.createdAt,
                message: messageCoreData.message ?? "undefined",
                messageID: messageCoreData.messageID ?? "undefined",
                recipientUsername: messageCoreData.recipientUsername ?? "undefined",
                senderUsername: messageCoreData.senderUsername ?? "undefined",
                isSeen: messageCoreData.isSeen
            )
            conversation.messages.append(message)
        }
        return conversation
    }
}
