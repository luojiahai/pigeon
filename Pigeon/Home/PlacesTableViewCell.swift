//
//  PlacesTableViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/13.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesTableViewCell: UITableViewCell {

    var place: GMSPlace? {
        didSet {
            textLabel?.text = place?.name
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
