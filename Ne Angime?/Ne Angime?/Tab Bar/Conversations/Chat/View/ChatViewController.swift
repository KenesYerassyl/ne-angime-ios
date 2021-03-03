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
    
    var chatViewModel: ChatViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        chatViewModel?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel?.fetchConversation()
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        if chatViewModel != nil {
            return chatViewModel!.getCurrentUser()
        } else {
            return Sender(senderId: "undefined", displayName: "Ne Angime?")
        }
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        if chatViewModel != nil {
            return chatViewModel!.getMessage(at: indexPath.section)
        } else {
            return Message(
                sender: Sender(senderId: "undefined", displayName: "Ne Angime?"),
                messageId: "undefined",
                sentDate: Date(),
                kind: .text("undefined")
            )
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if chatViewModel != nil {
            return chatViewModel!.getNumberOfMessages()
        } else {
            return 0
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {}
extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, chatViewModel != nil else { return }
        messageInputBar.inputTextView.text = nil
        chatViewModel!.didTapSendButton(text)
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func updateCollectionView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}
