//
//  FootprintCollectionViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit

class FootprintCollectionViewCell: UICollectionViewCell {
    
    var footprint: Footprint? {
        didSet {
            setupFootprint()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupFootprint() {
        if let url = footprint?.user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        nameLabel.text = footprint?.user?.name
        
        usernameLabel.text = "@" + (footprint?.user?.username)!
        
        footprintTextLabel.text = footprint?.text
        
        footprintLocationLabel.text = footprint?.place
        
        
        if let seconds = footprint?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    fileprivate func setupViews() {
        backgroundColor = .white
        
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(seperatorLineView)
        addSubview(footprintTextLabel)
        addSubview(footprintLocationLabel)
        addSubview(timeLabel)
        
        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        
        usernameLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        
        seperatorLineView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 8).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        footprintTextLabel.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor, constant: 8).isActive = true
        footprintTextLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        footprintTextLabel.widthAnchor.constraint(equalToConstant: frame.size.width - 24).isActive = true
        footprintTextLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        footprintLocationLabel.topAnchor.constraint(equalTo: footprintTextLabel.bottomAnchor, constant: 8).isActive = true
        footprintLocationLabel.leftAnchor.constraint(equalTo: footprintTextLabel.leftAnchor).isActive = true
        
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "nameLabel"
        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let footprintTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "footprintTextLabel"
        label.font = UIFont.systemFont(ofSize: 18)
        label.sizeToFit()
        return label
    }()
    
    let footprintLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.text = "footprintLocationLabel"
        label.font = UIFont.systemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.text = "timeLabel"
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }()
    
}
