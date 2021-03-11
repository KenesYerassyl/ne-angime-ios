//
//  SenderType.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/6/21.
//

import Foundation
import MessageKit


struct Sender: SenderType, Equatable {
    public static let undefined = Sender(senderId: "undefined", displayName: "undefined")
    var senderId: String
    var displayName: String
    
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
    
    static func == (left: Sender, right: Sender) -> Bool {
        return (left.senderId == right.senderId)
    }
    static func == (left: SenderType, right: Sender) -> Bool {
        return (left.senderId == right.senderId)
    }
    static func == (left: Sender, right: SenderType) -> Bool {
        return (left.senderId == right.senderId)
    }
}
