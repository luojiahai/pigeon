//
//  Meswift
//  Pigeon
//
//  Created by Tina Luan on 3/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class MeView: UIView {
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = .groupTableViewBackground
        
        addSubview(nameCardView)
        addSubview(nameLabel)
        addSubview(usernameLabel)
        addSubview(profilePhotoImageView)
        addSubview(editProfileButton)
        
        nameCardView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameCardView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nameCardView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nameCardView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        profilePhotoImageView.topAnchor.constraint(equalTo: nameCardView.topAnchor, constant: 16).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: nameCardView.leftAnchor, constant: 16).isActive = true
        profilePhotoImageView.bottomAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: -16).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalTo: profilePhotoImageView.heightAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 20).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        editProfileButton.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 20).isActive = true
        editProfileButton.rightAnchor.constraint(equalTo: nameCardView.rightAnchor, constant: -20).isActive = true
        editProfileButton.bottomAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: -16).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 24)
    }
    let nameCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderColor = lineColor.cgColor
        view.layer.borderWidth = linePixel
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 20)
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
    
    let editProfileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        //button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
    }()
    
}
