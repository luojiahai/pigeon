//
//  PendingFriendsTableViewCell.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class PendingFriendsTableViewCell: UITableViewCell {

    var user: User? {
        didSet {
            setupUser()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUser() {
        nameLabel.text = user?.name
        
        if let username = user?.username {
            usernameLabel.text = "@" + username
        }
        
        if let url = user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
    }
    
    fileprivate func setupViews() {
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(profilePhotoImageView)
        addSubview(approveButton)
        
        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 16).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        approveButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        approveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        approveButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        approveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = linePixel
        imageView.layer.borderColor = lineColor.cgColor
        return imageView
    }()
    
    let approveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("Approve", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        return button
    }()
    
}
