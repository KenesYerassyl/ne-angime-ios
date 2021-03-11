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
        if let username = UserDefaults.standard.string(forKey: "username"),
           let firstname = UserDefaults.standard.string(forKey: "firstname"),
           let lastname = UserDefaults.standard.string(forKey: "lastname"),
           let avatar = UserDefaults.standard.string(forKey: "avatar") {
            return Sender(senderId: username, displayName: "Ne Angime?")
        } else {
            print("Unexpected error 1")
            return Sender.undefined
        }
    }()
    
    init(conversationID: String) {
        self.conversationID = conversationID
        let otherUsername = UserManager.shared.getOtherUsername(from: conversationID)
        self.otherUser = Sender(senderId: otherUsername, displayName: "Ne Angime?")
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    weak var delegate: ChatViewModelDelegate?
    
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
        messages.append(MessageMessageKit(
            sender: currentUser,
            messageId: messageWebSocket.messageID,
            sentDate: Date(timeIntervalSince1970: messageWebSocket.createdAt),
            kind: .text(text)
        ))
        delegate?.updateCollectionView()
    }
    
    @objc private func newMessageToHandle(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let conversationID = userInfo["conversationID"] as? String,
              let dataWebSocket = userInfo["messageWebSocket"] as? MessageWebSocket else { return }
        if conversationID == self.conversationID && dataWebSocket.type == .receiveMessage {
            messages.append(MessageMessageKit(
                sender: dataWebSocket.senderUsername == otherUser.senderId ? otherUser : currentUser,
                messageId: dataWebSocket.messageID,
                sentDate: Date(timeIntervalSince1970: dataWebSocket.createdAt),
                kind: .text(dataWebSocket.message)
            ))
            DispatchQueue.main.async {
                self.delegate?.updateCollectionView()
            }
        }
    }
    
    func fetchConversation() {
        CoreDataManager.shared.getConversation(conversationID: conversationID) { [weak self] (conversation, error) in
            if let conversation = conversation, let messagesCoreData = conversation.messages?.allObjects as? [MessageCoreData] {
                var messages = [MessageType]()
                for item in messagesCoreData {
                    guard let senderUsername = item.senderUsername,
                          let senderUser = senderUsername == self?.otherUser.senderId ? self?.otherUser : self?.currentUser else { return }
                    messages.append(MessageMessageKit(
                        sender: senderUser,
                        messageId: item.messageID ?? "undefined",
                        sentDate: Date(timeIntervalSince1970: item.createdAt),
                        kind: .text(item.message ?? "undefined")
                    ))
                }
                messages.sort { (messageType1, messageType2) -> Bool in
                    return messageType1.sentDate < messageType2.sentDate
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.delegate?.updateCollectionView()
                }
            } else if let error = error {
                print("Error in fetching a chat: \(error)")
            }
        }
    }
}
