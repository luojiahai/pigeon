//
//  testAuthentication.swift
//  PigeonTestsNew
//
//  Created by Meng Yuan on 29/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase

@testable import Pigeon


class testAuthentication: XCTestCase {
    
    var loginVC: LoginViewController!
    
    override func setUp() {
        super.setUp()
        loginVC = Pigeon.LoginViewController(nibName: "Login", bundle: Bundle.main)
    }
    
    override func tearDown() {
        loginVC = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewLoad() {
        let loginView = loginVC.loginView
        
        XCTAssertNil(loginView, "view did not load")
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
    
    func testEmailIsValid() {
        XCTAssert(!loginVC.isValidEmail("123"), "numbers should be invalid")
        XCTAssert(!loginVC.isValidEmail("123@c"), "no extension should be false")
        XCTAssert(loginVC.isValidEmail("abby@aaa.com"), "should be valid")
    }
    
    
    
}
