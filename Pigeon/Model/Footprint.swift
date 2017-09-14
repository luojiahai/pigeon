//
//  Footprint.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 10/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation

class Footprint: NSObject {
    
    var footprintID: String?
    
    var user: User?
    var text: String?
    var timestamp: NSNumber?
    var imageURLs: [String]?
    var place: String?
    
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    
    var likes: [String]?
    var numComments: UInt?
    
    init(_ id: String) {
        footprintID = id
    }
    
}
