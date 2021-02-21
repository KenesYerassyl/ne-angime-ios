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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var conversations = [Conversation]()
    
    func getNumberOfItems() -> Int {
        return conversations.count
    }
    
    func getLastMessage(at index: Int) -> String {
        guard let messages = conversations[index].messages?.allObjects as? [MessageCoreData],
              let message = messages.last?.message else { return "undefined" }
        return message
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
}
