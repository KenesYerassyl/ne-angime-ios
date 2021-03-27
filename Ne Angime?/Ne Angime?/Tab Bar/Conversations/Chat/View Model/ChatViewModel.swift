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
                guard let error = error else { return }
                print("Error in sending data: \(error)")
            })
        } catch {
            print("Error in encoding message: \(error)")
        }
        guard let createdAt = messageWebSocket.createdAt else { fatalError("Message creation time date or message content is nil") }
        messages.append(MessageMessageKit(
            sender: currentUser,
            messageId: messageWebSocket.messageID,
            sentDate: Date(timeIntervalSince1970: createdAt),
            kind: .text(text),
            isSeen: false
        ))
        delegate?.updateCollectionView()
    }
    
    @objc private func newMessageToHandle(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String,
              let messageWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket else { return }
        
        guard let createdAt = messageWebSocket.createdAt,
              let messageContent =  messageWebSocket.message
        else { fatalError("Message creation time date or message content is nil") }
        
        if conversationID == self.conversationID && messageWebSocket.type == .receiveMessage {
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
    }
    
    @objc func fetchConversation() {
        CoreDataManager.shared.getConversation(conversationID: conversationID) { [weak self] (conversation) in
            guard let conversation = conversation, let messagesCoreData = conversation.messages?.allObjects as? [MessageCoreData] else { return }
            var messages = [MessageMessageKit]()
            for item in messagesCoreData {
                guard let senderUsername = item.senderUsername,
                      let senderUser = senderUsername == self?.otherUser.senderId ? self?.otherUser : self?.currentUser else { return }
                messages.append(MessageMessageKit(
                    sender: senderUser,
                    messageId: item.messageID ?? "undefined",
                    sentDate: Date(timeIntervalSince1970: item.createdAt),
                    kind: .text(item.message ?? "undefined"),
                    isSeen: item.isSeen
                ))
            }
            messages.sort { (messageType1, messageType2) -> Bool in
                return messageType1.sentDate < messageType2.sentDate
            }
            if self?.messages != messages {
                self?.messages = messages
                DispatchQueue.main.async { self?.delegate?.updateCollectionView() }
            }
        }
    }
}
