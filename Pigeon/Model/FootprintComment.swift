//
//  FootprintComment.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 14/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation

/*
 * Footprint commets are seperated from footprint class
 * to imporve efficiency.
 */
class FootprintComment: NSObject {
    
    var footprintID: String?
    
    var user: User?
    var text: String?
    var timestamp: NSNumber?
    
    init(_ id: String, _ dictionary: [String : AnyObject]) {
        footprintID = id
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
}
