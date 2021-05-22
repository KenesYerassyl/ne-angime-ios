//
//  ChatViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/17/21.
//

import MessageKit

protocol ChatViewModelDelegate: class {
    func updateCollectionView()
}

class ChatViewModel {
    var conversationID: String
    var otherUser: Sender
    let currentUser: Sender = {
        if let username = UserDefaults.standard.string(forKey: "username") {
            return Sender(senderId: username, displayName: "Ne Angime?")
        } else {
            print("Unexpected error 1")
            return Sender.undefined
        }
    }()
    weak var delegate: ChatViewModelDelegate?
    
    init(conversationID: String) {
        self.conversationID = conversationID
        let otherUsername = UserManager.shared.getOtherUsername(from: conversationID)
        self.otherUser = Sender(senderId: otherUsername, displayName: "Ne Angime?")
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchConversation), name: .conversationsAreLoadedFromDB, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(messageWasSeen), name: .messageWasSeen, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var messages = [MessageMessageKit]()
    
    func getMessage(at section: Int) -> MessageMessageKit {
        return messages[section]
    }
    
    func getNumberOfMessages() -> Int {
        return messages.count
    }
    
    func getCurrentUser() -> Sender {
        return currentUser
    }
    
    func didTapSendButton(_ text: String) {
        let messageWebSocket = MessageWebSocket(
            type: .sendMessage,
            message: text,
            messageID: UUID().uuidString,
            conversationID: conversationID,
            senderUsername: currentUser.senderId,
            recipientUsername: otherUser.senderId,
            createdAt: Date().timeIntervalSince1970
        )
        MessageHandler.shared.handleMessage(messageWebSocket: messageWebSocket)
        do {
            let data = try JSONEncoder().encode(messageWebSocket)
            WebSocket.shared.webSocketTask?.send(.data(data), completionHandler: { (error) in
                if let error = error {
                    print("Error in sending data: \(error)")
                } else {
                    guard let createdAt = messageWebSocket.createdAt else { fatalError("Message creation time date or message content is nil") }
                    self.messages.append(MessageMessageKit(
                        sender: self.currentUser,
                        messageId: messageWebSocket.messageID,
                        sentDate: Date(timeIntervalSince1970: createdAt),
                        kind: .text(text),
                        isSeen: false
                    ))
                    DispatchQueue.main.async { self.delegate?.updateCollectionView() }
                }
            })
        } catch {
            print("Error in encoding message: \(error)")
        }
    }
    
    @objc private func newMessageToHandle(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let messageWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket else { return }
        
        guard let createdAt = messageWebSocket.createdAt,
              let messageContent =  messageWebSocket.message
        else { fatalError("Message creation time date or message content is nil") }
        
        guard messageWebSocket.conversationID == self.conversationID && messageWebSocket.type == .receiveMessage else { return }
        messages.append(MessageMessageKit(
            sender: otherUser,
            messageId: messageWebSocket.messageID,
            sentDate: Date(timeIntervalSince1970: createdAt),
            kind: .text(messageContent),
            isSeen: false
        ))
        DispatchQueue.main.async {
            self.delegate?.updateCollectionView()
        }
    }
    
    @objc private func messageWasSeen(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let messageWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket,
              messageWebSocket.senderUsername == currentUser.senderId else { return }
        
        guard messageWebSocket.conversationID == self.conversationID && messageWebSocket.type == .getMessageStatusSeen else { return }
        for index in stride(from: 0, to: messages.count, by: 1) {
            if messages[index].messageId == messageWebSocket.messageID  {
                assert(messages[index].sender == currentUser)
                messages[index].isSeen = true
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
                break
            }
        }
    }
    
    @objc func fetchConversation() {
        guard let messagesRealm = RealmManager().getConversation(conversationID: conversationID)?.messages else { return }
        var messages = [MessageMessageKit]()
        for message in messagesRealm {
            let senderUser = message.senderUsername == otherUser.senderId ? otherUser : currentUser
            messages.append(MessageMessageKit(
                sender: senderUser,
                messageId: message.messageID,
                sentDate: Date(timeIntervalSince1970: message.createdAt),
                kind: .text(message.message),
                isSeen: message.isSeen
            ))
        }
        if self.messages != messages {
            self.messages = messages
            delegate?.updateCollectionView()
        }
    }
}
