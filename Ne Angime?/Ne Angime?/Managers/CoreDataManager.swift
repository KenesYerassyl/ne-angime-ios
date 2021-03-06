//
//  CoreDataManager.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/21/21.
//

import Foundation
import CoreData

class CoreDataManager {
    public static let shared = CoreDataManager()
    private init(){}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Ne Angime?")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func doesConversationExist(_ conversationID: String) -> Bool {
        let request = Conversation.fetchRequest() as NSFetchRequest<Conversation>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        var results = [NSManagedObject]()
        do {
            results = try context.fetch(request)
        } catch {
            print("Checking for existence \(conversationID) error: \(error)")
        }
        return results.count > 0
    }
    
    public func getConversation(conversationID: String, _ completion: @escaping(Conversation?, Error?) -> Void) {
        let request = Conversation.fetchRequest() as NSFetchRequest<Conversation>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        do {
            let results = try context.fetch(request) as [Conversation]
            var resultConversation: Conversation?
            for conversation in results {
                if conversation.conversationID == conversationID {
                    resultConversation = conversation
                    break
                }
            }
            guard let conversation = resultConversation else { return }
            completion(conversation, nil)
        } catch {
            print("Error in getting conversation by ID error: \(error)")
            completion(nil, error)
        }
    }
    
    public func getAllConversations(_ completion: @escaping([Conversation]?, Error?) -> Void) {
        let request = Conversation.fetchRequest() as NSFetchRequest<Conversation>
        do {
            let results = try context.fetch(request) as [Conversation]
            completion(results, nil)
        } catch {
            print("Error in getting all conversations: \(error)")
            completion(nil, error)
        }
    }
    
    public func deleteAllData() {
//        let request1 = Conversation.fetchRequest() as NSFetchRequest<Conversation>
//        do {
//            let results = try context.fetch(request1) as [Conversation]
//            for item in results {
//                context.delete(item)
//                saveContext()
//            }
//        } catch {
//            print("Error in getting all conversations: \(error)")
//        }
//        let request2 = MessageCoreData.fetchRequest() as NSFetchRequest<MessageCoreData>
//        do {
//            let results = try context.fetch(request2) as [MessageCoreData]
//            for item in results {
//                context.delete(item)
//                saveContext()
//            }
//        } catch {
//            print("Error in getting all conversations: \(error)")
//        }
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Conversation")
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        do {
            try CoreDataManager.shared.context.persistentStoreCoordinator?.execute(
                deleteRequest1,
                with: CoreDataManager.shared.context
            )
        } catch {
            print("Error in deleting conversations: \(error)")
        }

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Conversation")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        do {
            try CoreDataManager.shared.context.persistentStoreCoordinator?.execute(
                deleteRequest2,
                with: CoreDataManager.shared.context
            )
        } catch {
            print("Error in deleting conversations: \(error)")
        }
    }
    public func updateConversations(conversations: [Conversation]) {
        deleteAllData()
        for conversation in conversations {
            let newConversation = Conversation(context: context)
            newConversation.conversationID = conversation.conversationID
            guard let messages = conversation.messages as? Set<MessageCoreData> else { return }
            for message in messages {
                let newMessage = MessageCoreData(context: context)
                newMessage.conversation = newConversation
                newMessage.createdAt = message.createdAt
                newMessage.message = message.message
                newMessage.messageID = message.messageID
                newMessage.recipientUsername = message.recipientUsername
                newMessage.senderUsername = message.senderUsername
                newConversation.addToMessages(newMessage)
            }
            saveContext()
        }
    }
}
