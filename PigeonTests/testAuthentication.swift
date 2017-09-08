//
//  testAuthentication.swift
//  PigeonTests
//
//  Created by Meng Yuan on 6/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase

@testable import Pigeon

class testAuthentication: XCTestCase {
    
    var loginVC: LoginViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        loginVC = Pigeon.LoginViewController(nibName: "Login", bundle: Bundle.main)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testEmailPassword() {
        //should be false
        let loginView = loginVC.loginView
        
        XCTAssertNotNil(loginView, "view not loaded")

        loginView.emailTextField.text = "demo@gmail.com"
        loginView.passwordTextField.text = "123123"
        
        let email = loginView.emailTextField.text
        let password = loginView.passwordTextField.text
        
        XCTAssertNotNil(email, "email field is nil")
        XCTAssertNotNil(password, "password field is nil")
        
        loginVC.loginToDatabase(email: email!, password: password!)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            let user = Auth.auth().currentUser
            
            XCTAssertNotNil(user, "login failed")
        }
    }
    
}
