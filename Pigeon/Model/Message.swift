//
//  Message.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 5/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromUID: String?
    var toUID: String?
    var text: String?
    var timestamp: NSNumber?
    
    var targetUser: User?
    
    func chatTargetID() -> String? {
        return fromUID == Auth.auth().currentUser?.uid ? toUID : fromUID
    }
    
    init(_ dictionary: [String: AnyObject]) {
        fromUID = dictionary["fromUID"] as? String
        toUID = dictionary["toUID"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
}

