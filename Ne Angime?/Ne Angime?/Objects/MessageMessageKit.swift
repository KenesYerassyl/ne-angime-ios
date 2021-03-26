//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import MessageKit

struct MessageMessageKit: MessageType, Equatable {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    static func == (lhs: MessageMessageKit, rhs: MessageMessageKit) -> Bool {
        if lhs.sender.displayName != rhs.sender.displayName { return false }
        if lhs.sender.senderId != rhs.sender.senderId { return false }
        if lhs.messageId != rhs.messageId { return false }
        if lhs.sentDate != rhs.sentDate { return false }
        return true
    }
    
    static func != (lhs: MessageMessageKit, rhs: MessageMessageKit) -> Bool {
        if lhs.sender.displayName != rhs.sender.displayName { return true }
        if lhs.sender.senderId != rhs.sender.senderId { return true }
        if lhs.messageId != rhs.messageId { return true }
        if lhs.sentDate != rhs.sentDate { return true }
        return false
    }
}
