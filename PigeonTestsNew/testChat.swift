//
//  testChat.swift
//  PigeonTestsNew
//
//  Created by Meng Yuan on 29/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase

@testable import Pigeon

class testChat: XCTestCase {
    
    var chatsVC : ChatsViewController!
    var loginVC : LoginViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        loginVC = Pigeon.LoginViewController(nibName: "Login", bundle: Bundle.main)
        loginVC.loginToDatabase(email: "test123@gmail.com", password: "abcabc")
        chatsVC = Pigeon.ChatsViewController(style: UITableViewStyle.grouped)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChats() {
        
        XCTAssert(chatsVC.messages != nil, "chats view not fetched.")
        
        
    }
    
    
    
}
