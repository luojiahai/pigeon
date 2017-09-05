//
//  MainController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 11/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class MainController: UITabBarController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Setup tab bar
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        // Singleton
        let loginVC = LoginViewController.sharedInstance
        loginVC.delegates = [LoginViewControllerDelegate]()
        
        // Home
        let homeVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        // homeVC is one of the delegates for loginVC. It performs reloading data on itself
        loginVC.delegates?.append(homeVC)
        // homeVC has a navigation
        let homeNC = UINavigationController(rootViewController: homeVC)
        // tabBarItem is accessible from homeNC because homeNC is created in UITabBarController
        homeNC.tabBarItem.title = "Home"
        homeNC.tabBarItem.image = UIImage(named: "icons8-Home")
        homeNC.tabBarItem.selectedImage = UIImage(named: "icons8-Home Filled")
        
        // Chats
        let chatsVC = ChatsViewController()
	    loginVC.delegates?.append(chatsVC)
        let chatsNC = UINavigationController(rootViewController: chatsVC)
        chatsNC.tabBarItem.title = "Chats"
        chatsNC.tabBarItem.image = UIImage(named: "icons8-Speech Bubble")
        chatsNC.tabBarItem.selectedImage = UIImage(named: "icons8-Speech Bubble Filled")
        
        // Contacts
        let contactsVC = ContactsViewController()
        loginVC.delegates?.append(contactsVC)
        let contactsNC = UINavigationController(rootViewController: contactsVC)
        contactsNC.tabBarItem.title = "Contacts"
        contactsNC.tabBarItem.image = UIImage(named: "icons8-Contact")
        contactsNC.tabBarItem.selectedImage = UIImage(named: "icons8-Contact Filled")
        
        // Me
        let meVC = MeViewController()
        loginVC.delegates?.append(meVC)
        let meNC = UINavigationController(rootViewController: meVC)
        meNC.tabBarItem.title = "Me"
        meNC.tabBarItem.image = UIImage(named: "icons8-User")
        meNC.tabBarItem.selectedImage = UIImage(named: "icons8-User Filled")
        
        // Add all navigations
        viewControllers = [homeNC, chatsNC, contactsNC, meNC]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Authenticate user
        authenticate()
    }
    
    func authenticate() {
        guard let currentUser = Auth.auth().currentUser else {
            self.present(LoginViewController.sharedInstance, animated: false, completion: nil)
            return
        }
    }
    
}

