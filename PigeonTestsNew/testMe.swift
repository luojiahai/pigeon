//
//  testMe.swift
//  PigeonTestsNew
//
//  Created by Meng Yuan on 29/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase

@testable import Pigeon

class testMe: XCTestCase {
    
    var meVC : MeViewController!
    var loginVC : LoginViewController!
    
    override func setUp() {
        super.setUp()
        loginVC = Pigeon.LoginViewController(nibName: "Login", bundle: Bundle.main)
        loginVC.loginToDatabase(email: "test123@gmail.com", password: "abcabcabc")
        meVC = Pigeon.MeViewController(nibName: "Me", bundle: Bundle.main)
        let meView = meVC.meView
        let user = Auth.auth().currentUser
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        loginVC = nil
        meVC = nil
        super.tearDown()
    }
    
    func testImage() {
        
        loginVC.loginToDatabase(email: "test123@gmail.com", password: "abcabcabc")
        let meView = meVC.meView
        
        let user = Auth.auth().currentUser
        
        XCTAssertEqual(user?.photoURL?.absoluteString, meView.profilePhotoImageView.imageURLString)
        
    }
    
    func testUserName() {
        
        loginVC.loginToDatabase(email: "test123@gmail.com", password: "abcabcabc")
        let meView = meVC.meView
        
        let user = Auth.auth().currentUser
        
        XCTAssertEqual(user?.displayName, meView.nameLabel.text)
        
    }
    
    func testFootprint() {
        loginVC.loginToDatabase(email: "test123@gmail.com", password: "abcabcabc")
        
        //will pass after posting at least one footprint
        
        
        XCTAssert(meVC.footprints.count == 0, "footprints not loaded")
    }
    
    
}
