//
//  SenderType.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation
import MessageKit


struct Sender: SenderType, Equatable {
    var senderId: String
    var displayName: String
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
    
    static func == (left: Sender, right: Sender) -> Bool {
        return (left.senderId == right.senderId)
    }
}
