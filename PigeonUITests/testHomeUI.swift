//
//  testHomeUI.swift
//  PigeonUITests
//
//  Created by Xiong Hang Chen on 30/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest

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
    
        let pigeonNavigationBar = app.navigationBars["Pigeon"]
        pigeonNavigationBar.buttons["icons8 Map Marker Filled 50"].tap()
        app.navigationBars["Map"].buttons["Cancel"].tap()
        
        pigeonNavigationBar.buttons["icons8 Cat Footprint Filled 50"].tap()
        app.navigationBars["Post Footprint"].buttons["Cancel"].tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"@jeffrey")/*[[".cells.containing(.staticText, identifier:\"📍University of Melbourne\")",".cells.containing(.staticText, identifier:\"15:10 30\/09\/2017\")",".cells.containing(.staticText, identifier:\"@jeffrey\")",".cells.containing(.staticText, identifier:\"JEFFREY\")"],[[[-1,3],[-1,2],[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.buttons["icons8 Heart 50"].tap()
        
        let collectionView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .collectionView).element
        collectionView.tap()
        app.navigationBars["Footprint"].buttons[""].tap()
        //collectionView.cells.containing(.staticText, identifier: "@jeffrey").buttons["FootprintCell"].tap()
        //collectionView.swipeUp()
        
        
    }
    
}
