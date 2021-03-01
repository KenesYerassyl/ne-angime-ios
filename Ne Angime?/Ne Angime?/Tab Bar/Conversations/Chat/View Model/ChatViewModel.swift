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
    
    init(conversationID: String, otherUser: Sender) {
        self.conversationID = conversationID
        self.otherUser = otherUser
        NotificationCenter.default.addObserver(self, selector: #selector(newMessageToHandle), name: .newMessage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private let webSocket = (UIApplication.shared.delegate as! AppDelegate).webSocket
    weak var delegate: ChatViewModelDelegate?
    let currentUser: Sender = {
        if let username = UserDefaults.standard.string(forKey: "username") {
            return Sender(senderId: username, displayName: "Ne Angime?")
        } else {
            print("This will not happen")
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
        guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
        let messageWebSocket = MessageWebSocket(
            message: text,
            messageID: UUID().uuidString,
            userID: userID,
            createdAt: Date().timeIntervalSince1970
        )
        let dataWebSocket = DataWebSocket(type: .sendMessage, username: otherUser.senderId, message: messageWebSocket)
        MessageHandler.shared.handleMessage(dataWebSocket: dataWebSocket)
        do {
            let data = try JSONEncoder().encode(dataWebSocket)
            webSocket.webSocketTask?.send(.data(data), completionHandler: { (error) in
                guard let error = error else { return }
                print("Error in sending data: \(error)")
            })
        } catch {
            print("Error in encoding message: \(error)")
        }
        messages.append(Message(
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
              let dataWebSocket = userInfo["dataWebSocket"] as? DataWebSocket else { return }
        if conversationID == self.conversationID && dataWebSocket.type == .receiveMessage {
            messages.append(Message(
                sender: Sender(senderId: dataWebSocket.username, displayName: "Ne Angime?"),
                messageId: dataWebSocket.message.messageID,
                sentDate: Date(timeIntervalSince1970: dataWebSocket.message.createdAt),
                kind: .text(dataWebSocket.message.message)
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
                    messages.append(Message(
                        sender: (item.isSenderMe ? self.currentUser : self.otherUser),
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
