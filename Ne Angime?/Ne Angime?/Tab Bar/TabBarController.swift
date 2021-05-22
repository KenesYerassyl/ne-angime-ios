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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signOut), name: .signOut, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        tabBar.tintColor = UIColor(hex: "#30289f")
        navigationItem.title = "Conversations"
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(
            self,
            action: #selector(locationButtonClicked),
            imageName: "location_icon",
            size: CGSize(width: 40, height: 40),
            tintColor: UIColor(hex: "#30289f")
        )
        
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
        findViewController.title = "Find"
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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // Action function for FindViewController
    @objc private func clearButtonClicked() {
        findViewController.clearButtonClicked()
    }
    // Action function for ConversationViewController
    @objc private func locationButtonClicked() {
        conversationsViewController.locationButtonClicked()
    }
    // Action function for Sign Out
    @objc func signOut() {
        if let refreshToken = UserDefaults.standard.string(forKey: "refresh_token"),
           let data = try? JSONSerialization.data(withJSONObject: ["refresh_token" : refreshToken]) {
            var deletionRequest = APIRequest(method: .delete, path: "user/auth/logout")
            deletionRequest.body = data
            APIClient().request(deletionRequest, isAccessTokenRequired: false) { (_, response, error) in
                if response != nil{
                    UserDefaults.standard.removeObject(forKey: "username")
                    UserDefaults.standard.removeObject(forKey: "firstname")
                    UserDefaults.standard.removeObject(forKey: "lastname")
                    UserDefaults.standard.removeObject(forKey: "email")
                    UserDefaults.standard.removeObject(forKey: "access_token")
                    UserDefaults.standard.removeObject(forKey: "refresh_token")
                    UserDefaults.standard.removeObject(forKey: "user_id")
                    UserDefaults.standard.removeObject(forKey: "avatar")
                    WebSocket.shared.disconnect()
                    RealmManager().deleteAll()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if let error = error {
                    print("Error in logging out: \(error)")
                } else {
                    print("Unexpected error occured: data, response, and error are all nil.")
                }
            }
        } else {
            fatalError("Logging out failed: No refresh token or failure in serializing json data")
        }
    }
}

// TabBarController delegate extension
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tag = viewController.tabBarItem.tag
        if tag == 1 {
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(
                self,
                action: #selector(locationButtonClicked),
                imageName: "location_icon",
                size: CGSize(width: 40, height: 40),
                tintColor: UIColor(hex: "#30289f")
            )
            navigationItem.titleView = nil
        } else if tag == 2 {
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.rightBarButtonItem = nil
            navigationItem.titleView = nil
        } else if tag == 3 {
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Clear",
                style: .done,
                target: self,
                action: #selector(clearButtonClicked)
            )
            navigationItem.titleView = viewController.navigationItem.titleView
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.rightBarButtonItem = nil
            navigationItem.titleView = nil
        }
        navigationItem.title = viewController.title
    }
}
