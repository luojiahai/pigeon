//
//  testContactUI.swift
//  PigeonUITests
//
//  Created by Xiong Hang Chen on 5/10/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest

class testContactUI: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        
        if (app.navigationBars["Pigeon"].exists) {
            //logout of pigeon
            let tabBarsQuery = app.tabBars
            tabBarsQuery.buttons["Me"].tap()
            app.navigationBars["Me"].buttons["icons8 More Filled 50"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Log Out"]/*[[".cells.staticTexts[\"Log Out\"]",".staticTexts[\"Log Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.alerts["Warning"].buttons["Yes"].tap()
        }
        
        // enter email on login
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("demo@gmail.com")
        // enter password
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123123")
        app.buttons["Login"].tap()
        app.tabBars.buttons["Contacts"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Pending Friends"].tap()
        app.navigationBars["Pending Friends"].buttons["Contacts"].tap()
        
        let navigationBarsQuery = app.navigationBars
        navigationBarsQuery.buttons["icons8 Add User Male Filled 50"].tap()
        
        let contactsButton = navigationBarsQuery.buttons["Contacts"]
        contactsButton.tap()
        
        tablesQuery.staticTexts["@jeffrey"].tap()
        contactsButton.tap()
        tablesQuery.searchFields["Search"].tap()
        app.buttons["Cancel"].tap()
    }
    
}
