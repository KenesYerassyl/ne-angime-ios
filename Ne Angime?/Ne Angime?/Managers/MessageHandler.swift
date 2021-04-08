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
        guard let createdAt = messageWebSocket.createdAt,
              let messageContent =  messageWebSocket.message
        else { fatalError("Message creation time date or message content is nil") }
        let realm = RealmManager()
        let messageRealm = MessageRealm(
            createdAt: createdAt,
            message: messageContent,
            messageID: messageWebSocket.messageID,
            recipientUsername: messageWebSocket.recipientUsername,
            senderUsername: messageWebSocket.senderUsername,
            isSeen: false
        )
        if realm.doesConversationExist(conversationID: messageWebSocket.conversationID) {
            realm.addMessages(to: messageWebSocket.conversationID, messages: [messageRealm.toMessage()])
            NotificationCenter.default.post(
                name: .newMessage,
                object: nil,
                userInfo: [
                    "conversationID" : messageWebSocket.conversationID,
                    "messageWebSocket" : messageWebSocket
                ]
            )
        } else {
            let conversationRealm = ConversationRealm(
                conversationID: messageWebSocket.conversationID,
                firstNameOfRecipient: "",
                lastNameOfRecipient: ""
            )
            let group = DispatchGroup()
            group.enter()
            UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: messageWebSocket.conversationID)) { user in
                guard let user = user else { return }
                conversationRealm.firstNameOfRecipient = user.firstname
                conversationRealm.lastNameOfRecipient = user.lastname
                group.leave()
            }
            group.notify(queue: .main) {
                let realm = RealmManager()
                realm.add(object: conversationRealm)
                realm.addMessages(to: messageWebSocket.conversationID, messages: [messageRealm.toMessage()])
                NotificationCenter.default.post(
                    name: .newConversation,
                    object: nil,
                    userInfo: ["conversationID" : messageWebSocket.conversationID]
                )
            }
        }
    }
}
