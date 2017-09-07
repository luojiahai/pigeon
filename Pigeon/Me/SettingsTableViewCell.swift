//
//  SettingsTableViewCell.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 8/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SettingsLabelTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(infoTextLabel)
        
        infoTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        infoTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let infoTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = NSTextAlignment.right
        label.sizeToFit()
        return label
    }()
    
}

class SettingsImageTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(infoImageView)
        
        infoImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        infoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        infoImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        infoImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var infoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        return imageView
    }()
    
}
