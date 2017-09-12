//
//  ChatsTableViewCell.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/4.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ChatsTableViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupChat()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupChat() {
        if message?.targetUsers?.count == 1 {
            guard let targetUser = message?.targetUsers?.first else { return }
            let attributedText = NSMutableAttributedString(string: targetUser.name!, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
            attributedText.append(NSAttributedString(string: "   @" + targetUser.username!, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
            nameLabel.attributedText = attributedText
            if let url = targetUser.profilePhotoURL {
                profilePhotoImageView.loadImageUsingCache(with: url)
            }
            
            lastUpdatedMessageLabel.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                lastUpdatedTimeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    fileprivate func setupViews() {
        addSubview(profilePhotoImageView)
        addSubview(nameLabel)
        addSubview(lastUpdatedMessageLabel)
        addSubview(lastUpdatedTimeLabel)
        
        lastUpdatedTimeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        lastUpdatedTimeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        
        profilePhotoImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profilePhotoImageView.topAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: lastUpdatedTimeLabel.leftAnchor, constant: -8).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        lastUpdatedMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        lastUpdatedMessageLabel.bottomAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor).isActive = true
        lastUpdatedMessageLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        lastUpdatedMessageLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
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
        return label
    }()
    
    let lastUpdatedMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    let lastUpdatedTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
        label.textColor = lineColor
        label.textAlignment = NSTextAlignment.right
        label.sizeToFit()
        return label
    }()
    
}
