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
    var currentUserAvatar: URL?
    var otherUserAvatar: URL?
    var completion: ((_ conversationID: String, _ index: Int) -> Void)?
    private var customInputBarView = UIView()
    
    init(conversationID: String) {
        self.chatViewModel = ChatViewModel(conversationID: conversationID)
        self.currentUserAvatar = URL(string: UserDefaults.standard.string(forKey: "avatar") ?? "")
        super.init(nibName: nil, bundle: nil)
        view.tag = 88
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        chatViewModel.delegate = self
        navigationItem.largeTitleDisplayMode = .never
        updateInputBar()
        UserManager.shared.getUser(username: chatViewModel.otherUser.senderId) { [weak self] user in
            guard let user = user else { return }
            self?.otherUserAvatar = URL(string: user.avatar ?? "")
            DispatchQueue.main.async { self?.messagesCollectionView.reloadData() }
        }
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
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !chatViewModel.getMessage(at: indexPath.section).isSeen else { return }
        completion?(chatViewModel.conversationID, indexPath.section)
    }
}

// Extension for messages data source
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
            avatarView.sd_setImage(with: currentUserAvatar, placeholderImage: UIImage(named: "profile_placeholder"))
        } else {
            avatarView.sd_setImage(with: otherUserAvatar, placeholderImage: UIImage(named: "profile_placeholder"))
        }
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.timeZone = .current
        guard let font = UIFont(name: "Avenir", size: 13) else { return nil }
        let timeLabel = NSAttributedString(
            string: dateFormatter.string(from: message.sentDate),
            attributes: [NSAttributedString.Key.font : font]
        )
        return timeLabel
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
}

// Extension for message kit custom delegates
extension ChatViewController: InputBarAccessoryViewDelegate, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        messageInputBar.inputTextView.text = nil
        chatViewModel.didTapSendButton(text.trimmingCharacters(in: .whitespacesAndNewlines))
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

// Extension for view model delegate
extension ChatViewController: ChatViewModelDelegate {
    func updateCollectionView() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}
