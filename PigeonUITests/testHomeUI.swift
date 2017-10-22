//
//  testHomeUI.swift
//  PigeonUITests
//
//  Created by Xiong Hang Chen on 30/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase
@testable import Pigeon

class testHomeUI: XCTestCase {
        
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
        
        //logout of pigeon
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Me"].tap()
        app.navigationBars["Me"].buttons["icons8 More Filled 50"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Log Out"]/*[[".cells.staticTexts[\"Log Out\"]",".staticTexts[\"Log Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.alerts["Warning"].buttons["Yes"].tap()
        
        // enter email on login
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("demo@gmail.com")
        // enter password
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123123")
        app.buttons["Login"].tap()
        tabBarsQuery.buttons["Home"].tap()

        //begin testing
        let pigeonNavigationBar = app.navigationBars["Pigeon"]
        pigeonNavigationBar.buttons["icons8 Map Marker Filled 50"].tap()
        app.navigationBars["Map"].buttons["Cancel"].tap()
        
        pigeonNavigationBar.buttons["icons8 Cat Footprint Filled 50"].tap()
        app.navigationBars["Post Footprint"].buttons["Cancel"].tap()
        app.collectionViews.cells.containing(.staticText, identifier:"15:10 30/09/2017").buttons["icons8 Heart 50"].tap()
        
        let navigationBarsQuery = app.navigationBars["Footprint"]
        navigationBarsQuery.buttons["Pigeon"].tap()
        
    }
    
}
