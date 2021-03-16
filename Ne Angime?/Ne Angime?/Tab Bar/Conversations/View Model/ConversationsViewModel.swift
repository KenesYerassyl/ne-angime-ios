//
//  ConversationsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import Foundation

protocol ConversationsViewModelDelegate: class {
    func updateCollectionView()
}

class ConversationsViewModel {
    
    weak var delegate: ConversationsViewModelDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(newConversationCreated), name: .newConversation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setMessagesToRead), name: .leavingConversation, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var conversations = [Conversation]()
    var users = [User]()
    
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
        guard let username = UserDefaults.standard.string(forKey: "username") else { return 48 }
        var counter = 0
        for message in conversations[index].messages {
            if !message.isRead && message.senderUsername == username { counter += 1 }
        }
        return counter
    }
    
    func getFullNameOfRecipient(at index: Int) -> String {
        var fullName = "undefined undefined"
        CoreDataManager.shared.getConversation(conversationID: conversations[index].conversationID) { conversationCoreData in
            guard let convo = conversationCoreData,
                  let firstName = convo.firstNameOfRecipient,
                  let lastName = convo.lastNameOfRecipient else { return }
            fullName = "\(firstName) \(lastName)"
        }
        return fullName
    }
    
    func getUserImageURL(at index: Int) -> URL? {
        if users.count - 1 < index { return nil }
        return URL(string: users[index].avatar ?? "")
    }
    
    func adjustUserToConversation() {
        users.removeAll()
        let group = DispatchGroup()
        for conversation in conversations {
            group.enter()
            UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: conversation.conversationID)) { [weak self] user in
                guard let user = user else { return }
                self?.users.append(user)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            DispatchQueue.main.async { self.delegate?.updateCollectionView() }
        }
    }
    
    func fetchAllConversations() {
        CoreDataManager.shared.getAllConversations { [weak self] results in
            guard let results = results else { return }
            self?.conversations.removeAll()
            for conversationCoreData in results {
                var conversationToAppend = conversationCoreData.convertToConversation()
                conversationToAppend.messages.sort { (message1, message2) -> Bool in
                    return message1.createdAt < message2.createdAt
                }
                self?.conversations.append(conversationToAppend)
            }
            print("call for adjusting 2")
            self?.adjustUserToConversation()
        }
        ConversationManager.shared.getAllConversations { [weak self] conversations in
            guard let conversationsFromDB = conversations, let self = self else { return }
            let group = DispatchGroup()
            var shouldGetConversationFromDB = false
            if conversationsFromDB.count != self.conversations.count {
                shouldGetConversationFromDB = true
                for conversation in conversationsFromDB {
                    if !ConversationManager.shared.doesConversationExist(conversation, in: self.conversations) {
                        group.enter()
                        CoreDataManager.shared.addConversation(conversation: conversation) { completed in
                            if completed == .success { group.leave() }
                        }
                    }
                }
            }
            for i in stride(from: 0, to: self.conversations.count, by: 1) {
                for j in stride(from: 0, to: conversationsFromDB.count, by: 1) {
                    if self.conversations[i] == conversationsFromDB[j] &&
                        self.conversations[i].messages.count != conversationsFromDB[j].messages.count {
                        shouldGetConversationFromDB = true
                        group.enter()
                        CoreDataManager.shared.addMessages(
                            to: conversationsFromDB[j].conversationID,
                            from: conversationsFromDB[j].messages,
                            startingIndex: self.conversations.count
                        ) { completed in
                            if completed == .success { group.leave() }
                        }
                    }
                }
            }
            group.notify(queue: .main) {
                if shouldGetConversationFromDB {
                    self.conversations = conversationsFromDB
                    print("call for adjusting 1")
                    self.adjustUserToConversation()
                }
            }
        }
    }
    
    @objc func newConversationCreated(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String else { return }
        CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation) in
            guard let conversation = conversation else { return }
            self.conversations.append(conversation.convertToConversation())
            DispatchQueue.main.async {
                self.delegate?.updateCollectionView()
            }
        }
    }
    
    @objc func newMessageToHandle(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String,
              let messageWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket else { return }
        for index in 0...self.conversations.count - 1 {
            if self.conversations[index].conversationID == conversationID {
                self.conversations[index].messages.append(Message( createdAt: messageWebSocket.createdAt,message: messageWebSocket.message, messageID: messageWebSocket.messageID, recipientUsername: messageWebSocket.recipientUsername, senderUsername: messageWebSocket.senderUsername))
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
                break
            }
        }
    }
    
    @objc func setMessagesToRead(notification: Notification) {
        guard let userInfo = notification.userInfo, let conversationID = userInfo["conversationID"] as? String else { return }
        for index in stride(from: 0, to: conversations.count, by: 1) {
            if conversations[index].conversationID == conversationID {
                for jndex in 0...conversations[index].messages.count - 1 {
                    conversations[index].messages[jndex].isRead = true
                }
                CoreDataManager.shared.setMessagesToRead(conversationID: conversationID)
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
                break
            }
        }
    }
}
