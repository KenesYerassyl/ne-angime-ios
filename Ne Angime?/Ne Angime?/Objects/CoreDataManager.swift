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
    
    func doesConversationExist(_ conversationID: String) -> Bool {
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
    
    func getConversation(conversationID: String, _ completion: @escaping(Conversation?, Error?) -> Void) {
        let request = Conversation.fetchRequest() as NSFetchRequest<Conversation>
        request.predicate = NSPredicate(format: "conversationID == %@", conversationID)
        var results = [NSManagedObject]()
        do {
            results = try context.fetch(request)
            guard let conversation = results.first as? Conversation else { return }
            completion(conversation, nil)
        } catch {
            print("Checking for existence \(conversationID) error: \(error)")
            completion(nil, error)
        }
    }
}
