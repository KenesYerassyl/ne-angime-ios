//
//  Message.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
