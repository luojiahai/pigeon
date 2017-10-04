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
        app.tabBars.buttons["Contacts"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Pending Friends"].tap()
        app.navigationBars["Pending Friends"].buttons["Contacts"].tap()
        
        let navigationBarsQuery = app.navigationBars
        navigationBarsQuery.buttons["icons8 Add User Male Filled 50"].tap()
        
        let contactsButton = navigationBarsQuery.buttons["Contacts"]
        contactsButton.tap()
        
        tablesQuery.staticTexts["@abby"].tap()
        contactsButton.tap()
        tablesQuery.searchFields["Search"].tap()
        app.buttons["Cancel"].tap()
    }
    
}
