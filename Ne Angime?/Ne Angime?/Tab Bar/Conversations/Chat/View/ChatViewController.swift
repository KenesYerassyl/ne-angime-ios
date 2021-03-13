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
    
    private var chatViewModel: ChatViewModel
    var currentUserImage: UIImage?
    var otherUserImage: UIImage?
    private var customInputBarView = UIView()
    
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
        addBackButton(withNormalColor: .normalDark, didTapBackButton: #selector(didTapBackButton))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.fetchConversation()
    }
    
    private func updateInputBar() {
        messageInputBar.backgroundView.backgroundColor = UIColor(hex: "#f2f2f2")
        messageInputBar.inputTextView.textContainerInset.bottom = view.bounds.height * 0.01
        messageInputBar.inputTextView.textContainerInset.top = view.bounds.height * 0.01
        messageInputBar.inputTextView.textContainerInset.left = view.bounds.width * 0.05

        messageInputBar.inputTextView.placeholder = "Write your message here..."
        messageInputBar.separatorLine.isHidden = true
        
        messageInputBar.sendButton.setImage(UIImage(named: "send_button_normal"), for: .normal)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
    }
}

extension ChatViewController {
    @objc private func didTapBackButton() {
        NotificationCenter.default.post(name: .leavingConversation, object: nil, userInfo: ["conversationID" : chatViewModel.conversationID])
        navigationController?.popViewController(animated: true)
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
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == chatViewModel.currentUser.senderId {
            avatarView.image = currentUserImage
        } else {
            avatarView.image = otherUserImage
        }
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
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text.isEmpty {
            messageInputBar.sendButton.setImage(UIImage(named: "send_button_normal"), for: .normal)
        } else {
            messageInputBar.sendButton.setImage(UIImage(named: "send_button_tapped"), for: .normal)
        }
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func updateCollectionView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    }
}
