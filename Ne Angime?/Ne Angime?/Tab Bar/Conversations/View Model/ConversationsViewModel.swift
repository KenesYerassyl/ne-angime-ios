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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var conversations = [Conversation]()
    
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
    
    func getFullNameOfRecipient(at index: Int, _ completion: @escaping(String) -> Void) {
        let group = DispatchGroup()
        var fullName = "undefined undefined"
        if CoreDataManager.shared.doesConversationExist(conversations[index].conversationID) {
            group.enter()
            CoreDataManager.shared.getConversation(conversationID: conversations[index].conversationID) { (conversationCoreData, error) in
                if let conversationCoreData = conversationCoreData,
                   let firstName = conversationCoreData.firstNameOfRecipient,
                   let lastName = conversationCoreData.lastNameOfRecipient {
                    fullName = "\(firstName) \(lastName)"
                    group.leave()
                } else if let error = error {
                    print("Error in fetcing conversation for getting fullname: \(error)")
                }
            }
        } else {
            group.enter()
            UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: conversations[index].conversationID)) { user in
                guard let user = user else { return }
                fullName = "\(user.firstname) \(user.lastname)"
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(fullName)
        }
    }
    
    func fetchAllConversations() {
        CoreDataManager.shared.getAllConversations { (results, error) in
            if let results = results {
                self.conversations.removeAll()
                for conversationCoreData in results {
                    var conversationToAppend = ConversationManager.shared.convertToConversation(from: conversationCoreData)
                    conversationToAppend.messages.sort { (message1, message2) -> Bool in
                        return message1.createdAt < message2.createdAt
                    }
                    self.conversations.append(conversationToAppend)
                }
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
                ConversationManager.shared.getAllConversations { (conversations, error) in
                    if let conversationsFromDB = conversations {
                        if conversationsFromDB.count != self.conversations.count {
                            self.conversations = conversationsFromDB
                            CoreDataManager.shared.updateConversations(conversations: conversationsFromDB)
                            DispatchQueue.main.async {
                                self.delegate?.updateCollectionView()
                            }
                        } else {
                            var index = 0
                            while index < self.conversations.count {
                                if self.conversations[index].messages.count != conversationsFromDB[index].messages.count {
                                    self.conversations = conversationsFromDB
                                    CoreDataManager.shared.updateConversations(conversations: conversationsFromDB)
                                    DispatchQueue.main.async {
                                        self.delegate?.updateCollectionView()
                                    }
                                    break
                                }
                                index += 1
                            }
                        }
                    } else if let error = error {
                        print("Error in fetching all conversations from DB: \(error)")
                    }
                }
                
            } else if let error = error {
                print("(Conversations VM) Error in fetching all conversations: \(error)")
            }
        }
    }
    
    @objc func newConversationCreated(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String else { return }
        CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation, error) in
            if let conversation = conversation {
                self.conversations.append(ConversationManager.shared.convertToConversation(from: conversation))
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
            } else if let error = error {
                print("Error in getting convo by ID: \(error)")
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
}
