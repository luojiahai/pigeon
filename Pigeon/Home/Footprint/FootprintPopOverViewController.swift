//
//  FootprintPopoverViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/19.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class FootprintopoverViewController: UIViewController {
    
    var footprint: Footprint? {
        didSet {
            setupFootprint()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    fileprivate func setupFootprint() {
        if let url = footprint?.user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        nameLabel.text = footprint?.user?.name
        
        if let username = footprint?.user?.username {
            usernameLabel.text = "@" + username
        }
        
        footprintTextView.text = footprint?.text
        
        if let seconds = footprint?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
    }
    
    fileprivate func setupViews() {
        // gray
        view.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        view.addSubview(profilePhotoImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(footprintTextView)
        view.addSubview(timeLabel)
        
        timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        
        profilePhotoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 14).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profilePhotoImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 14).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        footprintTextView.leftAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: -4).isActive = true
        footprintTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        footprintTextView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4).isActive = true
        footprintTextView.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -12).isActive = true
    }
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        imageView.isUserInteractionEnabled = true
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
    
    let footprintTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.text = "footprintTextView"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.sizeToFit()
        return textView
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
