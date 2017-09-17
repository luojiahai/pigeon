//
//  UserFriendsData.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 17/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation

class UserFriendsData: NSObject {
    
    static let shared = UserFriendsData()
    
    var contacts = [User]()
    var pendingFriends = [User]()
    
    func isFriend(_ uid: String) -> Bool {
        for contact in contacts {
            if contact.uid == uid {
                return true
            }
        }
        return false
    }
    
    func isPendingFriend(_ uid: String) -> Bool {
        for pendingFriend in pendingFriends {
            if pendingFriend.uid == uid {
                return true
            }
        }
        return false
    }
    
    func removeAll() {
        contacts.removeAll()
        pendingFriends.removeAll()
    }
    
}
