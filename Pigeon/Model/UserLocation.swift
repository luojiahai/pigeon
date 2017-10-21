//
//  UserLocation.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 16/10/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation
import CoreLocation

class UserLocation: NSObject {
    
    var user: User?
    
    var location: CLLocation?
    
    var annotationIndex: Int?
    
    init(_ index: Int, user: User, location: CLLocation?) {
        annotationIndex = index
        self.user = user
        self.location = location
    }
    
}

