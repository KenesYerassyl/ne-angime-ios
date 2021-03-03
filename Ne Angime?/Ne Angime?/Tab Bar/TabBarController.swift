//
//  ViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    private let conversationsViewController = ConversationsViewController()
    private let friendsViewController = FriendsViewController()
    private let findViewController = FindViewController()
    private let profileViewController = ProfileViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(hex: "#aba7f3")
        conversationsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        friendsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        findViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
        profileViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 4)
        viewControllers = [conversationsViewController, friendsViewController, findViewController, profileViewController]
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(signOut)
        )
        WebSocket.shared.resetTask()
        WebSocket.shared.connect()
    }
}

extension TabBarController {
    @objc func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "firstname")
        UserDefaults.standard.removeObject(forKey: "lastname")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "token")
        WebSocket.shared.disconnect()
        
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
        conversationsViewController.conversationsViewModel.conversations.removeAll()
        conversationsViewController.wereConversationsFetched = false
        conversationsViewController.updateCollectionView()
        
        navigationController?.popViewController(animated: true)
    }
}
