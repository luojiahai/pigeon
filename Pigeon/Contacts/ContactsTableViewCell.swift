//
//  ContactsTableViewCell.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    var contact: User? {
        didSet {
            setupUser()
        }
    }

}
