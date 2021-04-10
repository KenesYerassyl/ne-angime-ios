//
//  RealmManager.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 4/6/21.
//

import Foundation
import RealmSwift

class RealmManager {
    
    var database: Realm
    
    init() {
        let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            let fiftyMB = 50 * 1024 * 1024
//            let totalBytesInMB = Double(totalBytes) * (0.000001)
//            let usedBytesInMB = Double(usedBytes) * (0.000001)
//            print("Total bytes in MB: \(totalBytesInMB)")
//            print("Used bytes in MB: \(usedBytesInMB)")
            return (totalBytes > fiftyMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        self.database = try! Realm(configuration: config)
    }
    func add<T: Object>(object: T) {
        do {
            try database.write {
                database.add(object)
            }
        } catch {
            print("Error in adding object to Realm: \(error), \(error.localizedDescription)")
        }
    }
    func delete<T: Object>(object: T) {
        do {
            try database.write {
                database.delete(object)
            }
        } catch {
            print("Error in deleting object to Realm: \(error), \(error.localizedDescription)")
        }
    }
    func deleteAll() {
        do {
            try database.write {
                database.deleteAll()
            }
        } catch {
            print("Error in deleting all data from Realm: \(error), \(error.localizedDescription)")
        }
    }
    func doesConversationExist(conversationID: String) -> Bool {
        let results = database.objects(ConversationRealm.self).filter("conversationID == '\(conversationID)'")
        assert(results.count <= 1)
        return !results.isEmpty
    }
    
    func doesMessageExist(messageID: String) -> Bool {
        let results = database.objects(MessageRealm.self).filter("messageID == '\(messageID)'")
        assert(results.count <= 1)
        return !results.isEmpty
    }
    
    func getConversation(conversationID: String) -> ConversationRealm? {
        let results = database.objects(ConversationRealm.self).filter("conversationID == '\(conversationID)'")
        assert(results.count <= 1)
        return results.first
    }
    
    func getAllConversations() -> [ConversationRealm] {
        let results = database.objects(ConversationRealm.self)
        return results.toArray(ofType: ConversationRealm.self)
    }
    
    func addMessages(to conversationID: String, messages: [Message]) {
        let results = database.objects(ConversationRealm.self).filter("conversationID == '\(conversationID)'")
        assert(results.count <= 1)
        do {
            guard let conversationRealm = results.first else { return }
            try database.write {
                for message in messages {
                    if !doesMessageExist(messageID: message.messageID) {
                        let messageRealm = message.toMessageRealm()
                        database.add(messageRealm)
                        conversationRealm.messages.append(messageRealm)
                    }
                }
            }
        } catch {
            print("Error in adding messages to Realm: \(error), \(error.localizedDescription)")
        }
    }
    
    func setMessageStatusSeen(from conversationID: String, messageID: String) {
        let resultsForConversation = database.objects(ConversationRealm.self).filter("conversationID == '\(conversationID)'")
        assert(resultsForConversation.count <= 1)
        let resultsForMessage = database.objects(MessageRealm.self).filter("messageID == '\(messageID)'")
        assert(resultsForMessage.count <= 1)
        do {
            try database.write {
                resultsForMessage.first?.isSeen = true
            }
        } catch {
            print("Error in updating a message from Realm: \(error), \(error.localizedDescription)")
        }
    }
}
