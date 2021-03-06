//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import MessageKit

struct MessageMessageKit: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
