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
    
    let meView = MeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = meView;
        
        setupNavigation()

        fetchUser()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Me"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "signOut", style: .plain, target: self, action: #selector(handleSignOut))
    }
    
    fileprivate func supportViews() {
        
        meView.editProfileButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
    }
    
    fileprivate func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let name = dataSnapshot.childSnapshot(forPath: "name").value as? String else { return }
            guard let username = dataSnapshot.childSnapshot(forPath: "username").value as? String else { return }
            guard let url = dataSnapshot.childSnapshot(forPath: "profilePhotoURL").value as? String else { return }
            self.meView.nameLabel.text = name
            self.meView.usernameLabel.text = username
            self.meView.profilePhotoImageView.loadImageUsingCache(with: url)
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
    
}

// MARK: - LoginViewControllerDelegate
// MeViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension MeViewController: LoginViewControllerDelegate {
    func reloadData() {
        fetchUser()
    }
}
