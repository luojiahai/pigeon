//
//  testHome.swift
//  PigeonTestsNew
//
//  Created by Meng Yuan on 29/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import XCTest
import Firebase
import CoreLocation

@testable import Pigeon

class testHome: XCTestCase {
    
    var homeVC: HomeViewController!
    var loginVC:LoginViewController!
    var postFootprintVC: PostFootprintViewController!
    var placeVC: PlacesViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        loginVC = Pigeon.LoginViewController(nibName: "Login", bundle: Bundle.main)
        loginVC.loginToDatabase(email: "abigail_yuan@hotmail.com", password: "yuanmeng960426")
        homeVC = HomeViewController(collectionViewLayout: UICollectionViewFlowLayout())
        postFootprintVC = PostFootprintViewController(nibName: "PostFootprint", bundle: Bundle.main)
        placeVC = PlacesViewController(nibName: "Places", bundle: Bundle.main)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        homeVC = nil
        postFootprintVC = nil
        placeVC = nil
        super.tearDown()
    }
    
    func testNetwork(){
        
        //To pass this test, need to login on the simulator first
        XCTAssert(Auth.auth().currentUser?.email == "abigail_yuan@hotmail.com", "cannot post footprint from correct user")
    }
        func testFootprintsTable() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(loginVC != nil, "login view not loaded")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            XCTAssert(self.homeVC.footprints.count != 0, "footprints not loaded") //should not be 0
        })
    }
    
    func testPostFootprint() {
        XCTAssert(loginVC != nil, "login view not loaded")
        
        placeVC.nearbyPlaces()
        
        postFootprintVC.selectedPlace = placeVC.likeHoodList?.likelihoods[0].place
        
        postFootprintVC.captionTextView.text = "a test for p[osting footprints"
        
        
        
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let place = placeVC.likeHoodList?.likelihoods[0].place
        
        let values = ["user": Auth.auth().currentUser?.uid as Any, "timestamp": timestamp, "text": "a test text", "place": place?.name as Any] as [String : Any]
        let images:[UIImage]? = [UIImage]()
        
        let location = CLLocation(latitude: 1.22334, longitude: 3.343242)
        
        postFootprintVC.updatePosts(values, location, images)
        
        XCTAssert(postFootprintVC.captionTextView != nil, "footprint is not showing in the text field.")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
