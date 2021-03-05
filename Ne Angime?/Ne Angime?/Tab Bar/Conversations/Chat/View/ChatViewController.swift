//
//  ChatViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/17/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    var chatViewModel: ChatViewModel
    
    init(conversationID: String) {
        self.chatViewModel = ChatViewModel(conversationID: conversationID)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        chatViewModel.delegate = self
        
        updateInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.fetchConversation()
    }
    
    private func updateInputBar() {
        messageInputBar.inputTextView.backgroundColor = UIColor(hex: "#f2f2f2")
        messageInputBar.separatorLine.height = 50
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

extension ChatViewController: InputBarAccessoryViewDelegate, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        messageInputBar.inputTextView.text = nil
        chatViewModel.didTapSendButton(text)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender as? Sender == chatViewModel.currentUser {
            return UIColor(hex: "#8f87ff")
        } else {
            return UIColor(hex: "#f2f2f2")
        }
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func updateCollectionView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}
