//
//  ConversationsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol ConversationsViewModelDelegate: class {
    func reloadCollectionView()
    func inChatViewController(with conversationID: String) -> Bool
}

class ConversationsViewModel {
    
    weak var delegate: ConversationsViewModelDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(newConversationCreated), name: .newConversation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Array consisting of conversation objects, stores all conversations
    var conversations = [Conversation]()
    // Dictionary with Key –> String and Value -> User Object
    var users = [String : User]()
    
    func getNumberOfItems() -> Int {
        return conversations.count
    }
    
    func getConversationID(at index: Int) -> String {
        return conversations[index].conversationID
    }
    
    func getLastMessage(at index: Int) -> String {
        guard let lastMessage = conversations[index].messages.last?.message else { return "undefined" }
        return lastMessage
    }
    
    func getNumberOfUnreadMessages(at index: Int) -> Int {
        guard let username = UserDefaults.standard.string(forKey: "username") else { fatalError("User is not logged in!") }
        var counter = 0
        for message in conversations[index].messages {
            if !message.isSeen && message.senderUsername != username { counter += 1 }
        }
        return counter
    }
    
    func getFullNameOfRecipient(at index: Int) -> String {
        let conversationRealm = RealmManager().getConversation(conversationID: conversations[index].conversationID)
        let fullName = "\(conversationRealm?.firstNameOfRecipient ?? "undefined") \(conversationRealm?.lastNameOfRecipient ?? "undefined")"
        return fullName
    }
    
    func getUserImageURL(from conversationID: String) -> URL? {
        guard let user = users[conversationID] else { return nil }
        return URL(string: user.avatar ?? "")
    }
    
    func adjustUserToConversation() {
        users.removeAll()
        let group = DispatchGroup()
        for conversation in conversations {
            group.enter()
            UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: conversation.conversationID)) { [weak self] user in
                guard let user = user else { return }
                self?.users[conversation.conversationID] = user
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.delegate?.reloadCollectionView()
        }
    }
    
    func fetchAllConversations() {
        for conversationRealm in RealmManager().getAllConversations() {
            var conversation = conversationRealm.toConversation()
            conversation.messages.sort { (message1, message2) -> Bool in
                return message1.createdAt < message2.createdAt
            }
            self.conversations.append(conversation)
        }
        adjustUserToConversation()
        
        ConversationManager.shared.getAllConversations { [weak self] conversations in
            guard let conversationsFromDB = conversations, let self = self else { return }
            let group = DispatchGroup()
            var shouldGetConversationFromDB = false
            if conversationsFromDB.count != self.conversations.count {
                shouldGetConversationFromDB = true
                for conversation in conversationsFromDB {
                    if !ConversationManager.shared.doesConversationExist(conversation, in: self.conversations) {
                        group.enter()
                        conversation.toConversationRealm { (conversationRealm) in
                            autoreleasepool {
                                let realm = RealmManager()
                                realm.database.refresh()
                                realm.add(object: conversationRealm)
                                group.leave()
                            }
                        }
                    }
                }
            }
            group.notify(queue: .main) {
                //starting in main thread
                // for loop running throug 'conversations' array
                for i in stride(from: 0, to: self.conversations.count, by: 1) {
                    for j in stride(from: 0, to: conversationsFromDB.count, by: 1) {
                        // for loop running throug 'conversationsFromDB' array
                        if self.conversations[i].conversationID == conversationsFromDB[j].conversationID &&
                            self.conversations[i] != conversationsFromDB[j] { //if their IDs are equal, but contents are not
                            shouldGetConversationFromDB = true
                            // Realm adds messages to it self
                            RealmManager().addMessages(to: conversationsFromDB[j].conversationID, messages: conversationsFromDB[j].messages)
                        }
                    }
                }
                if shouldGetConversationFromDB {
                    //load conversations and adjust users to them
                    self.conversations = conversationsFromDB
                    self.adjustUserToConversation()
                    NotificationCenter.default.post(name: .conversationsAreLoadedFromDB, object: nil)
                }
            }
        }
    }
    
    @objc func newConversationCreated(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String,
              var conversation = RealmManager().getConversation(conversationID: conversationID)?.toConversation() else { return }
        conversation.messages.sort { (message1, message2) -> Bool in
            return message1.createdAt < message2.createdAt
        }
        conversations.append(conversation)
        delegate?.reloadCollectionView()
    }
    
    @objc func newMessageToHandle(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let messageWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket else { return }
        
        guard let createdAt = messageWebSocket.createdAt,
              let messageContent =  messageWebSocket.message
        else { fatalError("Message creation time date or message content is nil") }
        
        for index in 0...self.conversations.count - 1 {
            if self.conversations[index].conversationID == messageWebSocket.conversationID {
                self.conversations[index].messages.append(
                    Message(
                        createdAt: createdAt,
                        message: messageContent,
                        messageID: messageWebSocket.messageID,
                        recipientUsername: messageWebSocket.recipientUsername,
                        senderUsername: messageWebSocket.senderUsername,
                        isSeen: self.delegate?.inChatViewController(with: self.conversations[index].conversationID) ?? false
                    )
                )
                DispatchQueue.main.async {
                    self.delegate?.reloadCollectionView()
                }
                break
            }
        }
    }
}
