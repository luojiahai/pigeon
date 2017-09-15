//
//  FootprintCollectionViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit
import Firebase

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
        
        if let username = footprint?.user?.username {
            usernameLabel.text = "@" + username
        }
        
        footprintTextView.text = footprint?.text
        
        if let place = footprint?.place {
            footprintLocationLabel.text = "📍" + place
        }
        
        if let imageURLs = footprint?.imageURLs {
            for index in 0..<3 {
                if index < imageURLs.count {
                    footprintImageViews[index].loadImageUsingCache(with: imageURLs[index])
                    footprintImageViews[index].isHidden = false
                } else {
                    footprintImageViews[index].isHidden = true
                }
            }
        } else {
            footprintImageViews.forEach({ (imageView) in
                imageView.isHidden = true
            })
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
        
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(seperatorLineView)
        addSubview(footprintTextView)
        addSubview(footprintLocationLabel)
        addSubview(timeLabel)
        addSubview(verticalLineView)
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(numLikesCommentsLabel)
        
        footprintImageViews.forEach { (imageView) in
            addSubview(imageView)
        }
        
        profilePhotoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        
        usernameLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        
        timeLabel.bottomAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 2).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        footprintTextView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 4).isActive = true
        footprintTextView.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 8).isActive = true
        footprintTextView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        footprintTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        var previousRightAnchor: NSLayoutXAxisAnchor?
        footprintImageViews.forEach { (imageView) in
            imageView.topAnchor.constraint(equalTo: footprintTextView.bottomAnchor).isActive = true
            if let prev = previousRightAnchor {
                imageView.leftAnchor.constraint(equalTo: prev, constant: 8).isActive = true
            } else {
                imageView.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 12).isActive = true
            }
            imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            previousRightAnchor = imageView.rightAnchor
        }
        
        footprintLocationLabel.bottomAnchor.constraint(equalTo: seperatorLineView.topAnchor, constant: -6).isActive = true
        footprintLocationLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 21).isActive = true
        
        verticalLineView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor).isActive = true
        verticalLineView.leftAnchor.constraint(equalTo: profilePhotoImageView.centerXAnchor).isActive = true
        verticalLineView.bottomAnchor.constraint(equalTo: footprintLocationLabel.topAnchor).isActive = true
        verticalLineView.widthAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        seperatorLineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        likeButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        likeButton.rightAnchor.constraint(equalTo: commentButton.leftAnchor, constant: -8).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        commentButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        commentButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        numLikesCommentsLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        numLikesCommentsLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "nameLabel"
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
    
    let verticalLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let footprintTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.text = "footprintTextView"
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.sizeToFit()
        return textView
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
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    var footprintImageViews: [CustomImageView] = {
        var imageViews = [CustomImageView]()
        for _ in 0..<3 {
            let imageView = CustomImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.layer.borderWidth = linePixel
            imageView.layer.borderColor = lineColor.cgColor
            imageView.isUserInteractionEnabled = true
            imageViews.append(imageView)
        }
        return imageViews
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Like", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Liked", for: .disabled)
        button.setTitleColor(.gray, for: .disabled)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Comment", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let numLikesCommentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "numLikesCommentsLabel"
        label.textColor = .gray
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }()
    
}
