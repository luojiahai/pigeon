//
//  MeViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController {
    
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        
        fetchUser()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Me"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "signOut", style: .plain, target: self, action: #selector(handleSignOut))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(nameCardView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(profilePhotoImageView)
        view.addSubview(editProfileButton)
        
        nameCardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nameCardView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nameCardView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameCardView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        profilePhotoImageView.topAnchor.constraint(equalTo: nameCardView.topAnchor, constant: 16).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: nameCardView.leftAnchor, constant: 16).isActive = true
        profilePhotoImageView.bottomAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: -16).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalTo: profilePhotoImageView.heightAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 20).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        editProfileButton.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 20).isActive = true
        editProfileButton.rightAnchor.constraint(equalTo: nameCardView.rightAnchor, constant: -20).isActive = true
        editProfileButton.bottomAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: -16).isActive = true
        editProfileButton.heightAnchor.constraint(equalToConstant: 24)
    }
    
    fileprivate func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let name = dataSnapshot.childSnapshot(forPath: "name").value as? String else { return }
            guard let username = dataSnapshot.childSnapshot(forPath: "username").value as? String else { return }
            guard let url = dataSnapshot.childSnapshot(forPath: "profilePhotoURL").value as? String else { return }
            self.nameLabel.text = name
            self.usernameLabel.text = username
            self.profilePhotoImageView.loadImageUsingCache(with: url)
        }
    }
    
    @objc fileprivate func handleSignOut() {
        do {
            try Auth.auth().signOut()
            present(LoginViewController.sharedInstance, animated: true, completion: nil)
        } catch let logoutError {
            let alert = UIAlertController(title: "Error", message: String(describing: logoutError), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func handleEditProfile() {
        let alert = UIAlertController(title: "Edit Profile", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 21)
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
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
    }()

}

// MARK: - LoginViewControllerDelegate
// MeViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension MeViewController: LoginViewControllerDelegate {
    func reloadData() {
        fetchUser()
    }
}
