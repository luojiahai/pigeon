//
//  Message.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 5/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

/*
 * The message class that defines all the attributes of a message object.
 * All the attributes are optional but will be used as concrete.
 */
class Message: NSObject {
    
    var conversationID: String?
    
    var fromUID: String?
    var text: String?
    var timestamp: NSNumber?
    
    var targetUser: User?
    var targetUsers: [User]?
    
    init(_ id: String, _ dictionary: [String: AnyObject]) {
        conversationID = id
        fromUID = dictionary["fromUID"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
    }
    
}

