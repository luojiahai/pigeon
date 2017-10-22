//
//  MeViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController, OptionsViewControllerDelegate, EditProfileDelegate {
    
    var user: User?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FootprintSimpleCollectionViewCell.self, forCellWithReuseIdentifier: "FootprintSimpleCell")
        return collectionView
    }()
    
    var refreshControl: UIRefreshControl?
    
    var footprints = [Footprint]()
    
    var profileChangedCompletion: (() -> Void)?
    
    let meView = MeView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        fetchUser()
        fetchFootprintsForMe()
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
    
    @objc fileprivate func reloadCollectionView() {
        footprints.removeAll()
        collectionView.reloadData()
        fetchFootprintsForMe()
        
        refreshControl?.endRefreshing()
    }
    // Setup the layout of navigation bar
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Me"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-QR Code Filled-50"), style: .plain, target: self, action: #selector(handleQRCode))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-More Filled-50"), style: .plain, target: self, action: #selector(handleOptions))
    }
    // When QRcode button has been touched
    @objc fileprivate func handleQRCode() {
        let qrVC = QRCodeViewController()
        qrVC.user = user
        let vc = UINavigationController(rootViewController: qrVC)
        present(vc, animated: true, completion: nil)
    }
    // Functions related to subviews
    fileprivate func supportViews() {
        meView.editProfileButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        
        meView.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: meView.nameCardView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: meView.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: meView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: meView.rightAnchor).isActive = true
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadCollectionView), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl!)
    }
    
    // Fetch the information about the current user
    fileprivate func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let dictionary = dataSnapshot.value as? [String : AnyObject] else { return }
            self.user = User(uid: dataSnapshot.key, dictionary)
            self.meView.nameLabel.text = self.user?.name
            self.meView.usernameLabel.text = "@" + (self.user?.username)!
            self.meView.profilePhotoImageView.loadImageUsingCache(with: (self.user?.profilePhotoURL)!)
        }
    }
    // When option button has been touched
    @objc fileprivate func handleOptions() {
        let vc = OptionsTableViewController(style: .grouped)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // When signout button has been touched
    func handleSignOut(completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
                if let completion = completion { completion() }
                self.present(LoginViewController.sharedInstance, animated: true, completion: nil)
            } catch let logoutError {
                let alert = UIAlertController(title: "Error", message: String(describing: logoutError), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleEditProfile() {
        let vc = EditProfileTableViewController(style: .grouped)
        vc.hidesBottomBarWhenPushed = true
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    // Footprints posted by the current user
    fileprivate func fetchFootprintsForMe() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("footprints").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let objects = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for object in objects {
                guard let uid = object.childSnapshot(forPath: "user").value as? String else { return }
                if currentUser.uid != uid {
                    continue
                }
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (userDataSnapshot) in
                    guard let userDictionary = userDataSnapshot.value as? [String: AnyObject] else { return }
                    let user = User(uid: uid, userDictionary)
                    let footprint = Footprint(object.key)
                    footprint.user = user
                    footprint.text = object.childSnapshot(forPath: "text").value as? String
                    footprint.timestamp = object.childSnapshot(forPath: "timestamp").value as? NSNumber
                    if object.hasChild("images") {
                        footprint.imageURLs = [String]()
                        guard let imageURLs = object.childSnapshot(forPath: "images").children.allObjects as? [DataSnapshot] else { return }
                        for imageURL in imageURLs {
                            let image = imageURL.value as? String
                            footprint.imageURLs?.append(image!)
                        }
                    }
                    footprint.place = object.childSnapshot(forPath: "place").value as? String
                    guard let location = object.childSnapshot(forPath: "location").value as? [String: Any] else { return }
                    footprint.latitude = location["latitude"] as? Double
                    footprint.longitude = location["longitude"] as? Double
                    footprint.altitude = location["altitude"] as? Double
                    if object.hasChild("likes") {
                        guard let likes = object.childSnapshot(forPath: "likes").value as? [String: AnyObject] else { return }
                        footprint.likes = Array(likes.keys)
                    }
                    footprint.numComments = object.childSnapshot(forPath: "comments").childrenCount
                    
                    self.footprints.insert(footprint, at: 0)
                    
                    DispatchQueue.main.async(execute: {
                        self.collectionView.reloadData()
                    })
                })
            }
        }
    }
    
}

// MARK: - LoginViewControllerDelegate
// MeViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension MeViewController: LoginViewControllerDelegate {
    
    @objc func reloadData() {
        fetchUser()
        
        reloadCollectionView()
    }
    
}
// Each cell in collections can be opened and seen as a footprint
extension MeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return footprints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FootprintSimpleCell", for: indexPath)
        
        if let cell = cell as? FootprintSimpleCollectionViewCell {
            cell.footprint = footprints[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let footprintVC = FootprintViewController()
        footprintVC.footprint = footprints[indexPath.row]
        footprintVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(footprintVC, animated: true)
    }
    
}
// Give the profile a image (take a photo or pick one from library)
extension MeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleChangeProfilePhoto(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Photos", style: .default) { (UIAlertAction) in self.openPhotoLibrary() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        self.profileChangedCompletion = completion
    }
    
    fileprivate func openCamera() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func openPhotoLibrary() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
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
                    if let completion = self.profileChangedCompletion {
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
