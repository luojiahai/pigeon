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
        
        let firstTab = UINavigationController(rootViewController: homeVC)
        firstTab.tabBarItem.title = "Home"
        
        // Chats
        let chatsVC = ChatsViewController()
        
        let secondTab = UINavigationController(rootViewController: chatsVC)
        secondTab.tabBarItem.title = "Chats"
        
        // Contacts
        let contactsVC = ContactsViewController()
        
        let thirdTab = UINavigationController(rootViewController: contactsVC)
        thirdTab.tabBarItem.title = "Contacts"
        
        // Me
        let meVC = MeViewController()
        
        let fourthTab = UINavigationController(rootViewController: meVC)
        fourthTab.tabBarItem.title = "Me"
        
        // Add all tabs
        viewControllers = [firstTab, secondTab, thirdTab, fourthTab]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

