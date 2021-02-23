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
    
    public func handleMessage(dataWebSocket: DataWebSocket) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let senderUsername = (dataWebSocket.type == .sendMessage ? currentUsername : dataWebSocket.username)
        let recipientUsername = (dataWebSocket.type == .receiveMessage ? currentUsername : dataWebSocket.username)
        var conversationID = "undefined"
        if CoreDataManager.shared.doesConversationExist("\(senderUsername)&&\(recipientUsername)") {
            conversationID = "\(senderUsername)&&\(recipientUsername)"
        } else if CoreDataManager.shared.doesConversationExist("\(recipientUsername)&&\(senderUsername)") {
            conversationID = "\(recipientUsername)&&\(senderUsername)"
        }
        
        let message = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
        message.isSenderMe = (senderUsername == currentUsername)
        message.messageID = dataWebSocket.message.messageID
        message.message = dataWebSocket.message.message
        message.createdAt = dataWebSocket.message.createdAt
        
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
                            "dataWebSocket" : dataWebSocket
                        ]
                    )
                } else if let error = error {
                    print("Error occured in getting conversation: \(error)")
                }
            }
        } else {
            let conversation = Conversation(entity: Conversation.entity(), insertInto: CoreDataManager.shared.context)
            conversation.conversationID = "\(senderUsername)&&\(recipientUsername)"
            conversation.recipientUsername = dataWebSocket.username
            message.conversation = conversation
            conversation.addToMessages(message)
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(
                name: .newConversation,
                object: nil,
                userInfo: ["conversationID" : "\(senderUsername)&&\(recipientUsername)"]
            )
        }
    }
}
