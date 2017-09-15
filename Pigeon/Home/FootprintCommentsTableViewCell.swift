//
//  FootprintCommentsTableViewCell.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 14/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class FootprintCommentsTableViewCell: UITableViewCell {
    
    var comment: FootprintComment? {
        didSet {
            setupComment()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupComment() {
        if let url = comment?.user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        nameLabel.text = comment?.user?.name
        
        if let username = comment?.user?.username {
            usernameLabel.text = "@" + username
        }
        
        commentTextLabel.text = comment?.text
        
        if let seconds = comment?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    fileprivate func setupViews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(commentTextLabel)
        addSubview(timeLabel)
        
        timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -6).isActive = true
        
        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profilePhotoImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 8).isActive = true
        
        usernameLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 8).isActive = true
        
        commentTextLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        commentTextLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        commentTextLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
    }
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "usernameLabel"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    let commentTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "commentTextLabel"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.sizeToFit()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "timeLabel"
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()
    
}
