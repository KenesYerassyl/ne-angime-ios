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
    
    func saveContext() {
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
    
    func doesConversationExist(_ conversationID: String) -> Bool {
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
    
    func getConversation(conversationID: String, _ completion: @escaping(ConversationCoreData?) -> Void) {
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
            guard let conversation = resultConversation else {
                completion(nil)
                return
            }
            completion(conversation)
        } catch {
            print("Error in getting conversation by ID error: \(error)")
            completion(nil)
        }
    }
    
    
    func getAllConversations(_ completion: @escaping([ConversationCoreData]?) -> Void) {
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        do {
            let results = try context.fetch(request) as [ConversationCoreData]
            completion(results)
        } catch {
            print("Error in getting all conversations: \(error)")
            completion(nil)
        }
    }
    
    func deleteAllData() {
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
        
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MessageCoreData")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        do {
            try CoreDataManager.shared.context.persistentStoreCoordinator?.execute(
                deleteRequest2,
                with: CoreDataManager.shared.context
            )
        } catch {
            print("Error in deleting messages: \(error)")
        }
    }
    
    func addConversation(conversation: Conversation, completion: @escaping(Result) -> Void) {
        let coreDataConversation = ConversationCoreData(entity: ConversationCoreData.entity(), insertInto: context)
        coreDataConversation.conversationID = conversation.conversationID
        let group = DispatchGroup()
        group.enter()
        UserManager.shared.getUser(username: UserManager.shared.getOtherUsername(from: conversation.conversationID)) { user in
            if let user = user {
                coreDataConversation.firstNameOfRecipient = user.firstname
                coreDataConversation.lastNameOfRecipient = user.lastname
                group.leave()
            } else {
                completion(.failure)
            }
        }
        group.notify(queue: .main) {
            for message in conversation.messages {
                coreDataConversation.addToMessages(message.convertToMessageCoreData())
            }
            self.saveContext()
            completion(.success)
        }
    }
    
    func setMessageStatusSeen(from conversationID: String, message: Message) {
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        do {
            let results = try context.fetch(request) as [ConversationCoreData]
            guard results.first != nil,
                  results.first!.conversationID == conversationID,
                  let messages = results.first!.messages?.allObjects as? [MessageCoreData]
            else { fatalError("This conversation does not exist, which cannot be happened!") }
            
            for index in stride(from: 0, to: messages.count, by: 1) {
                if messages[index].messageID == message.messageID,
                   messages[index].createdAt == message.createdAt,
                   messages[index].message == message.message {
                    results.first!.removeFromMessages(messages[index])
                    results.first!.addToMessages(message.convertToMessageCoreData())
                    break
                }
            }
            DispatchQueue.main.async { self.saveContext() }
        } catch {
            print("Error in getting conversation by ID error: \(error)")
        }
    }
    
    func addMessages(to conversationID: String, from messages: [Message], completion: @escaping(Result) -> Void) {
        let request = ConversationCoreData.fetchRequest() as NSFetchRequest<ConversationCoreData>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        do {
            let results = try context.fetch(request) as [ConversationCoreData]
            guard results.first != nil && results.first!.conversationID == conversationID else { fatalError("This conversation does not exist, which cannot be happened!") }
            if results.first!.messages != nil { results.first!.removeFromMessages(results.first!.messages!) }
            for index in 0...messages.count - 1 {
                results.first!.addToMessages(messages[index].convertToMessageCoreData())
            }
            saveContext()
            completion(.success)
        } catch {
            completion(.failure)
            print("Error in getting conversation by ID error: \(error)")
        }
    }
}
