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
    
    init(conversationID: String) {
        self.conversationID = conversationID
        self.otherUser = Sender(senderId: UserManager.shared.getOtherUsername(from: conversationID), displayName: "Ne Angime?")
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    weak var delegate: ChatViewModelDelegate?
    let currentUser: Sender = {
        if let username = UserDefaults.standard.string(forKey: "username") {
            return Sender(senderId: username, displayName: "Ne Angime?")
        } else {
            print("This will not happen 1")
            return Sender(senderId: "undefined", displayName: "Ne Angime?")
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
                sender: Sender(senderId: dataWebSocket.senderUsername, displayName: "Ne Angime?"),
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
        CoreDataManager.shared.getConversation(conversationID: conversationID) { (conversation, error) in
            if let conversation = conversation, let messagesCoreData = conversation.messages?.allObjects as? [MessageCoreData] {
                var messages = [MessageType]()
                for item in messagesCoreData {
                    messages.append(MessageMessageKit(
                        sender: Sender(senderId: item.senderUsername ?? "undefined", displayName: "Ne Angime?"),
                        messageId: item.messageID ?? "undefined",
                        sentDate: Date(timeIntervalSince1970: item.createdAt),
                        kind: .text(item.message ?? "undefined")
                    ))
                }
                messages.sort { (messageType1, messageType2) -> Bool in
                    return messageType1.sentDate < messageType2.sentDate
                }
                self.messages = messages
                DispatchQueue.main.async {
                    self.delegate?.updateCollectionView()
                }
            } else if let error = error {
                print("Error in fetching a chat: \(error)")
            }
        }
    }
}
