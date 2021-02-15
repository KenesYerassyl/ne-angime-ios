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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "username") == nil {
            let navigationController = UINavigationController(rootViewController: SignInViewController())
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: false)
        }
    }
}

