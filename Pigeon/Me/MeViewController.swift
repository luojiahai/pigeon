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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        fetchUser()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = meView
        
        supportViews()
        
        setupNavigation()
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
            self.meView.usernameLabel.text = "@" + username
            self.meView.profilePhotoImageView.loadImageUsingCache(with: url)
        }
    }
    
    @objc fileprivate func handleSignOut() {
        let alert = UIAlertController(title: "Warning", message: "Are you sure want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
                self.present(LoginViewController.sharedInstance, animated: true, completion: nil)
            } catch let logoutError {
                let alert = UIAlertController(title: "Error", message: String(describing: logoutError), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleEditProfile() {
        let vc = EditProfileTableViewController(style: .grouped)
        vc.hidesBottomBarWhenPushed = true
        vc.meVC = self
        navigationController?.pushViewController(vc, animated: true)
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

extension MeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleChangeProfilePhoto(completion: (() -> Void)? = nil) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        self.completion = completion
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            meView.profilePhotoImageView.image = selectedImage
        }
        
        let imageName = NSUUID().uuidString
        if let profileImage = meView.profilePhotoImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.25) {
            Storage.storage().reference().child("profile_images").child("\(imageName).png").putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let url = metadata?.downloadURL()?.absoluteString {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    Database.database().reference().child("users").child(uid).updateChildValues(["profilePhotoURL": url])
                }
                
                DispatchQueue.main.async(execute: {
                    if let completion = self.completion {
                        completion()
                    }
                })
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
