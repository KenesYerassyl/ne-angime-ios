//
//  MessageHandler.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/22/21.
//

import Foundation

class MessageHandler {
    public static let shared = MessageHandler()
    private init(){}
    
    public func handleMessage(messageWebSocket: MessageWebSocket) {
        var conversationID = "undefined"
        if CoreDataManager.shared.doesConversationExist("\(messageWebSocket.senderUsername)&&\(messageWebSocket.recipientUsername)") {
            conversationID = "\(messageWebSocket.senderUsername)&&\(messageWebSocket.recipientUsername)"
        } else if CoreDataManager.shared.doesConversationExist("\(messageWebSocket.recipientUsername)&&\(messageWebSocket.senderUsername)") {
            conversationID = "\(messageWebSocket.recipientUsername)&&\(messageWebSocket.senderUsername)"
        }
        
        let message = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
        message.messageID = messageWebSocket.messageID
        message.message = messageWebSocket.message
        message.createdAt = messageWebSocket.createdAt
        message.recipientUsername = messageWebSocket.recipientUsername
        message.senderUsername = messageWebSocket.senderUsername
        
        if conversationID != "undefined" {
            CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation, error) in
                if let conversation = conversation {
                    message.conversation = conversation
                    conversation.addToMessages(message)
                    CoreDataManager.shared.saveContext()
                    NotificationCenter.default.post(
                        name: .newMessage,
                        object: nil,
                        userInfo: [
                            "conversationID" : conversationID,
                            "messageWebSocket" : messageWebSocket
                        ]
                    )
                } else if let error = error {
                    print("Error occured in getting conversation: \(error)")
                }
            }
        } else {
            let conversation = Conversation(entity: Conversation.entity(), insertInto: CoreDataManager.shared.context)
            conversation.conversationID = "\(messageWebSocket.senderUsername)&&\(messageWebSocket.recipientUsername)"
            message.conversation = conversation
            conversation.addToMessages(message)
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(
                name: .newConversation,
                object: nil,
                userInfo: ["conversationID" : "\(messageWebSocket.senderUsername)&&\(messageWebSocket.recipientUsername)"]
            )
        }
    }
}
