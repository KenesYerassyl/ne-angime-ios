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
        if let conversationID = conversations[index].conversationID {
            return conversationID
        } else {
            return "undefined"
        }
    }
    
    func getLastMessage(at index: Int) -> String {
        guard let messages = conversations[index].messages?.allObjects as? [MessageCoreData] else { return "undefined" }
        var dateOfLastMessage: Double = 0
        var lastMessage = "undefined"
        
        for item in messages {
            if item.createdAt > dateOfLastMessage {
                guard let message = item.message else { return "undefined" }
                lastMessage = message
                dateOfLastMessage = item.createdAt
            }
        }
        
        return lastMessage
    }
    
    func fetchAllConversations() {
        CoreDataManager.shared.getAllConversations { (results, error) in
            if let results = results {
                self.conversations = results
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
                ConversationManager.shared.getAllConversations { (conversations, error) in
                    if let conversationsFromDB = conversations {
                        if conversationsFromDB.count != self.conversations.count {
                            self.conversations = conversationsFromDB
//                            CoreDataManager.shared.updateConversations(conversations: conversationsFromDB)
                            DispatchQueue.main.async {
                                self.delegate?.updateCollectionView()
                            }
                        } else {
                            var index = 0
                            while index < self.conversations.count {
                                if self.conversations[index].messages?.count != conversationsFromDB[index].messages?.count {
                                    self.conversations = conversationsFromDB
//                                    CoreDataManager.shared.updateConversations(conversations: conversationsFromDB)
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
                self.conversations.append(conversation)
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
              let conversationID = userInfo["conversationID"] as? String else { return }
        CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation, error) in
            if let conversation = conversation {
                for index in 0...self.conversations.count - 1 {
                    if self.conversations[index].conversationID == conversationID {
                        self.conversations[index] = conversation
                        break
                    }
                }
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
            } else if let error = error {
                print("Error in getting convo by ID: \(error)")
            }
        }
    }
}
