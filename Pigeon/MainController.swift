//
//  MainController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 11/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class MainController: UITabBarController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Setup tab bar
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        // Home
        let homeVC = HomeViewController()
        
        let homeNC = UINavigationController(rootViewController: homeVC)
        homeNC.tabBarItem.title = "Home"
        
        // Chats
        let chatsVC = ChatsViewController()
        
        let chatsNC = UINavigationController(rootViewController: chatsVC)
        chatsNC.tabBarItem.title = "Chats"
        
        // Contacts
        let contactsVC = ContactsViewController()
        
        let contactsNC = UINavigationController(rootViewController: contactsVC)
        contactsNC.tabBarItem.title = "Contacts"
        
        // Me
        let meVC = MeViewController()
        
        let meNC = UINavigationController(rootViewController: meVC)
        meNC.tabBarItem.title = "Me"
        
        // Add all tabs
        viewControllers = [homeNC, chatsNC, contactsNC, meNC]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

