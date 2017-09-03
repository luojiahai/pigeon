//
//  HomeView.swift
//  Pigeon
//
//  Created by Tina Luan on 3/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class HomeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = .groupTableViewBackground
    }
}
