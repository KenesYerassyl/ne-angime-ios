//
//  ChatViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/17/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController {
    
    private var counter = 1
    private let currentUser = Sender(senderId: "kenesyerassyl", displayName: "Ne Angime")
    private let otherUser = Sender(senderId: "Soultan", displayName: "Ne Angime")
    private let chatViewModel = ChatViewModel()
    
    var messages = [MessageType]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate {}
extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print(text)
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        if counter % 2 == 0 {
            messages.append(Message(sender: otherUser, messageId: "\(counter)", sentDate: Date(), kind: .text(text)))
        } else {
            messages.append(Message(sender: currentSender(), messageId: "\(counter)", sentDate: Date(), kind: .text(text)))
        }
        counter += 1
        messageInputBar.inputTextView.text = nil
        messagesCollectionView.reloadDataAndKeepOffset()
        messagesCollectionView.scrollToLastItem()
    }
}
