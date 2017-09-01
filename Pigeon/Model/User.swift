//
//  User.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var uid: String?
    var username: String?
    var name: String?
    var email: String?
    var profilePhotoURL: String?
    
    var isPending: Bool?
    var isApproved: Bool?
    
    init(uid: String, _ dictionary: [String: AnyObject]) {
        self.uid = uid
        username = dictionary["username"] as? String
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        profilePhotoURL = dictionary["profilePhotoURL"] as? String
    }
    
}
