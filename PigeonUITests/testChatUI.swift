//
//  testChatUI.swift
//  PigeonUITests
//
//  Created by Xiong Hang Chen on 5/10/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest

class testChatUI: XCTestCase {
        
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
        app.tabBars.buttons["Chats"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Dun Dun   @ssswww4444"].tap()
   
        let textField = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textField).element
        textField.tap()
        textField.typeText("This is a UI test")
        app.buttons["Send"].tap()
        app.navigationBars["ssswww4444"].buttons["Chats"].tap()
        app.navigationBars.children(matching: .button).element.tap()
    }
    
}