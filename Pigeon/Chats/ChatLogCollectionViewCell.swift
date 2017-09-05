//
//  ChatLogCollectionViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/4.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ChatLogCollectionViewCell: UICollectionViewCell {
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profilePhotoImageView)
        
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12)
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 12).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8).isActive = true
        textView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.font = UIFont.systemFont(ofSize: 18)
        view.backgroundColor = .clear
        view.textColor = .black
        return view
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderColor = lineColor.cgColor
        view.layer.borderWidth = linePixel
        return view
    }()
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        return imageView
    }()
    
}
