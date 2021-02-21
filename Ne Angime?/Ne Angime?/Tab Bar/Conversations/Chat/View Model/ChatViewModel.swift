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
    weak var delegate: ChatViewModelDelegate?
    var otherUser = Sender(senderId: "undefined", displayName: "undefined")
    let currentUser: Sender = {
        if let username = UserDefaults.standard.string(forKey: "username"),
           let firstname = UserDefaults.standard.string(forKey: "firstname"),
           let lastname = UserDefaults.standard.string(forKey: "lastname") {
            return Sender(senderId: username, displayName: "\(firstname) \(lastname)")
        } else {
            return Sender(senderId: "undefined", displayName: "undefined")
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
            WebSocket.shared.webSocketTask?.send(.data(data), completionHandler: { (error) in
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
}
