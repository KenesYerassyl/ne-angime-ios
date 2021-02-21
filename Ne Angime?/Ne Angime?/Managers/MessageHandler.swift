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
        
        if CoreDataManager.shared.doesConversationExist("\(senderUsername)&&\(recipientUsername)") {
            //TODO: apend to current conversation
        } else if CoreDataManager.shared.doesConversationExist("\(recipientUsername)&&\(senderUsername)") {
            //TODO: apend to current conversation
        } else {
            let conversation = Conversation(entity: Conversation.entity(), insertInto: CoreDataManager.shared.context)
            conversation.conversationID = "\(senderUsername)&&\(recipientUsername)"
            conversation.recipientUsername = recipientUsername
            let message = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
            message.conversation = conversation
            message.isSenderMe = (senderUsername == currentUsername)
            message.messageID = dataWebSocket.message.messageID
            message.message = dataWebSocket.message.message
            message.createdAt = dataWebSocket.message.createdAt
            conversation.messages = [message]
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(
                name: .newConversation,
                object: nil,
                userInfo: ["conversationID" : "\(senderUsername)&&\(recipientUsername)"]
            )
        }
    }
}
