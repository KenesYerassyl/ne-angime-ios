//
//  ViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let conversationsViewController = ConversationsViewController()
    private let friendsViewController = FriendsViewController()
    private let findViewController = FindViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(hex: "#aba7f3")
        conversationsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        friendsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        findViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
        viewControllers = [conversationsViewController, friendsViewController, findViewController]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(signOut)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.string(forKey: "username") == nil {
            let navigationController = UINavigationController(rootViewController: SignInViewController())
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false)
        }
    }
}

extension TabBarController {
    @objc func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "firstname")
        UserDefaults.standard.removeObject(forKey: "lastname")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "token")
        WebSocket.shared.disconnect()
        let navigationController = UINavigationController(rootViewController: SignInViewController())
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
