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

    var chatViewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        chatViewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return chatViewModel.getCurrentUser()
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatViewModel.getMessage(at: indexPath.section)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatViewModel.getNumberOfMessages()
    }
}

extension ChatViewController: MessagesLayoutDelegate {}
extension ChatViewController: MessagesDisplayDelegate {}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        messageInputBar.inputTextView.text = nil
        chatViewModel.didTapSendButton(text)
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func updateCollectionView() {
        messagesCollectionView.reloadDataAndKeepOffset()
        messagesCollectionView.scrollToLastItem()
    }
}
