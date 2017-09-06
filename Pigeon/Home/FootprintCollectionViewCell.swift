//
//  FootprintCollectionViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit

class FootprintCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = .white
        
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(seperatorLineView)
        addSubview(footprintContentLabel)
        addSubview(footprintLocationLabel)
        addSubview(timeLabel)
        
        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        
        seperatorLineView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 8).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        footprintContentLabel.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor, constant: 8).isActive = true
        footprintContentLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        footprintContentLabel.widthAnchor.constraint(equalToConstant: frame.size.width - 24).isActive = true
        footprintContentLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        footprintLocationLabel.topAnchor.constraint(equalTo: footprintContentLabel.bottomAnchor, constant: 8).isActive = true
        footprintLocationLabel.leftAnchor.constraint(equalTo: footprintContentLabel.leftAnchor).isActive = true
        
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
        label.text = "nameLabel"
        label.sizeToFit()
        return label
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let footprintContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "footprintContentLabel"
        label.sizeToFit()
        return label
    }()
    
    let footprintLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.text = "footprintLocationLabel"
        label.sizeToFit()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.text = "timeLabel"
        label.sizeToFit()
        return label
    }()
    
}
