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
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        var results = [NSManagedObject]()
        do {
            results = try context.fetch(request)
        } catch {
            print("Checking for existence \(conversationID) error: \(error)")
        }
        return results.count > 0
    }
    
    public func getConversation(conversationID: String, _ completion: @escaping(ConversationCoreData?, Error?) -> Void) {
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        do {
            let results = try context.fetch(request) as [ConversationCoreData]
            var resultConversation: ConversationCoreData?
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
    
    public func getAllConversations(_ completion: @escaping([ConversationCoreData]?, Error?) -> Void) {
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        do {
            let results = try context.fetch(request) as [ConversationCoreData]
            completion(results, nil)
        } catch {
            print("Error in getting all conversations: \(error)")
            completion(nil, error)
        }
    }
    
    public func deleteAllData() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ConversationCoreData")
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        do {
            try CoreDataManager.shared.context.persistentStoreCoordinator?.execute(
                deleteRequest1,
                with: CoreDataManager.shared.context
            )
        } catch {
            print("Error in deleting conversations: \(error)")
        }

        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ConversationCoreData")
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
        let group = DispatchGroup()
        for conversation in conversations {
            let conversationCoreData = ConversationCoreData(entity: ConversationCoreData.entity(), insertInto: context)
            group.enter()
            UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: conversation.conversationID)) { user in
                guard let user = user else { return }
                conversationCoreData.firstNameOfRecipient = user.firstname
                conversationCoreData.lastNameOfRecipient = user.lastname
                group.leave()
            }
            group.notify(queue: .main) {
                conversationCoreData.conversationID = conversation.conversationID
                for message in conversation.messages {
                    let messageCoreData = MessageCoreData(entity: MessageCoreData.entity(), insertInto: self.context)
                    messageCoreData.createdAt = message.createdAt
                    messageCoreData.message = message.message
                    messageCoreData.messageID = message.messageID
                    messageCoreData.recipientUsername = message.recipientUsername
                    messageCoreData.senderUsername = message.senderUsername
                    conversationCoreData.addToMessages(messageCoreData)
                }
                self.saveContext()
            }
        }
    }
}
