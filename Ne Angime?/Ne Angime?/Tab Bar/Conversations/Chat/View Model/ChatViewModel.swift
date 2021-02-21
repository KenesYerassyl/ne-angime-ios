//
//  ChatViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/17/21.
//

import MessageKit

protocol ChatViewModelDelegate: class {

}

class ChatViewModel {
    var otherUser = Sender(senderId: "undefined", displayName: "undefined")
    let currentUser: Sender = {
        if let username = UserDefaults.standard.string(forKey: "username"),
           let firstname = UserDefaults.standard.string(forKey: "firstname"),
           let lastname = UserDefaults.standard.string(forKey: "lastname") {
            return Sender(senderId: username, displayName: "\(firstname) \(lastname)")
        } else {
            return Sender(senderId: "undefined", displayName: "undefined")
        }
    }()
    
    var messages = [MessageType]()
    
    func getMessage(at section: Int) -> MessageType {
        return messages[section]
    }
    
    func getNumberOfMessages() -> Int {
        return messages.count
    }
    
    func getCurrentUser() -> Sender {
        return currentUser
    }
    
    func didTapSendButton(_ text: String) {
        if CoreDataManager.shared.doesConversationExist("\(currentUser.senderId)&&\(otherUser.senderId)") ||
            CoreDataManager.shared.doesConversationExist("\(otherUser.senderId)&&\(currentUser.senderId)") {
            //TODO: apend to current conversation
        } else {
            let conversation = Conversation(entity: Conversation.entity(), insertInto: CoreDataManager.shared.context)
            conversation.conversationID = "\(currentUser.senderId)&&\(otherUser.senderId)"
            conversation.recipientUsername = "\(otherUser.senderId)"
            let message = MessageCoreData(entity: MessageCoreData.entity(), insertInto: CoreDataManager.shared.context)
            message.conversation = conversation
            message.isSenderMe = true
            message.messageID = UUID().uuidString
            message.message = text
            message.createdAt = Date().timeIntervalSince1970
            conversation.messages = [message]
            CoreDataManager.shared.saveContext()
            NotificationCenter.default.post(
                name: .newConversation,
                object: nil,
                userInfo: ["conversationID" : "\(currentUser.senderId)&&\(otherUser.senderId)"]
            )
        }
    }
}
