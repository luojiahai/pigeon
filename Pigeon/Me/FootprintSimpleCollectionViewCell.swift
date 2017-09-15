//
//  FootprintSimpleCollectionViewCell.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 14/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class FootprintSimpleCollectionViewCell: UICollectionViewCell {
    
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
        
        if let username = footprint?.user?.username {
            usernameLabel.text = "@" + username
            headerLabel.text = "FOOTPRINT  @" + username
        }
        
        footprintTextLabel.text = footprint?.text
        
        if let place = footprint?.place {
            footprintLocationLabel.text = "📍" + place
        }
        
        if let seconds = footprint?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
        
        var numLikesCommentsText = ""
        if let likes = footprint?.likes {
            numLikesCommentsText += String(likes.count) + " Likes "
        }
        if let numComments = footprint?.numComments, numComments > 0 {
            numLikesCommentsText += " " + String(numComments) + " Comments"
        }
        numLikesCommentsLabel.text = numLikesCommentsText
    }
    
    fileprivate func setupViews() {
        backgroundColor = .white
        
//        addSubview(profilePhotoImageView)
//        addSubview(nameLabel)
//        addSubview(usernameLabel)
        addSubview(headerLabel)
        addSubview(seperatorLineView)
        addSubview(footprintTextLabel)
        addSubview(footprintLocationLabel)
        addSubview(timeLabel)
        addSubview(verticalLineView)
        addSubview(numLikesCommentsLabel)
        
//        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
//        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
//        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
//        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
//
//        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
//        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
//
//        usernameLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
//        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        
        headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        headerLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        headerLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        headerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        seperatorLineView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        footprintTextLabel.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor, constant: 8).isActive = true
        footprintTextLabel.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 12).isActive = true
        footprintTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        footprintTextLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        footprintLocationLabel.topAnchor.constraint(equalTo: footprintTextLabel.bottomAnchor, constant: 4).isActive = true
        footprintLocationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
        verticalLineView.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        verticalLineView.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        verticalLineView.bottomAnchor.constraint(equalTo: footprintLocationLabel.topAnchor).isActive = true
        verticalLineView.widthAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        numLikesCommentsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        numLikesCommentsLabel.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
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
        label.numberOfLines = 1
        label.text = "footprintTextLabel"
        label.font = UIFont.systemFont(ofSize: 18)
        label.sizeToFit()
        return label
    }()
    
    let footprintLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .darkGray
        label.text = "footprintLocationLabel"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.text = "timeLabel"
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.sizeToFit()
        return label
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.text = "footprintLabel"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    let verticalLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let numLikesCommentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "numLikesCommentsLabel"
        label.textColor = .gray
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.sizeToFit()
        return label
    }()
    
}
