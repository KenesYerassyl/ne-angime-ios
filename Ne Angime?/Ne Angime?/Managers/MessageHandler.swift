//
//  MessageHandler.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/22/21.
//

import Foundation
import UIKit

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
        guard let createdAt = messageWebSocket.createdAt,
              let messageContent =  messageWebSocket.message
        else { fatalError("Message creation time date or message content is nil") }
        
        let message = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
        message.messageID = messageWebSocket.messageID
        message.message = messageContent
        message.createdAt = createdAt
        message.recipientUsername = messageWebSocket.recipientUsername
        message.senderUsername = messageWebSocket.senderUsername
        
        if conversationID != "undefined" {
            CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation) in
                guard let conversation = conversation else { return }
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
            }
        } else {
            let conversation = ConversationCoreData(entity: ConversationCoreData.entity(), insertInto: CoreDataManager.shared.context)
            let group = DispatchGroup()
            group.enter()
            UserManager.shared.getUser(username: messageWebSocket.senderUsername) { user in
                guard let user = user else { return }
                conversation.firstNameOfRecipient = user.firstname
                conversation.lastNameOfRecipient = user.lastname
                group.leave()
            }
            group.notify(queue: .main) {
                conversation.conversationID = "\(messageWebSocket.senderUsername)&&\(messageWebSocket.recipientUsername)"
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
}
