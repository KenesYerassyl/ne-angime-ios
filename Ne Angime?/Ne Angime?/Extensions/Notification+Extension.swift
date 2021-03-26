//
//  Notification+Extensions.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation

extension Notification.Name {
    static let newConversation = Notification.Name("New Conversation")
    static let newMessage = Notification.Name("New Message")
    static let conversationsAreLoadedFromDB = Notification.Name("Conversations are loaded from the database")
}
