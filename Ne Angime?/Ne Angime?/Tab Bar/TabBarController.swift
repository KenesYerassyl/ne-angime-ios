//
//  TabBarController.swift
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
        delegate = self
        tabBar.tintColor = UIColor(hex: "#30289f")
        conversationsViewController.tabBarItem = UITabBarItem(
            title: "Conversations",
            image: UIImage(named: "conversations_tab_bar_icon"),
            tag: 1
        )
        conversationsViewController.title = "Conversations"
        friendsViewController.tabBarItem = UITabBarItem(
            title: "Friends",
            image: UIImage(named: "friends_tab_bar_icon"),
            tag: 2
        )
        findViewController.tabBarItem = UITabBarItem(
            title: "Find",
            image: UIImage(named: "find_tab_bar_icon"),
            tag: 3
        )
        friendsViewController.title = "Friends"
        profileViewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(named: "profile_tab_bar_icon"),
            tag: 4
        )
        viewControllers = [conversationsViewController, friendsViewController, findViewController, profileViewController]
        WebSocket.shared.resetTask()
        WebSocket.shared.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 1 || viewController.tabBarItem.tag == 2 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        navigationItem.title = viewController.title
    }
}
