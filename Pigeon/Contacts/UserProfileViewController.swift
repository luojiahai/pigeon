//
//  UserProfileViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 16/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
            
            setupUser()
            fetchFootprintsForUser()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FootprintOnProfileCollectionViewCell.self, forCellWithReuseIdentifier: "FootprintOnProfileCell")
        return collectionView
    }()
    
    var refreshControl: UIRefreshControl?
    
    var footprints = [Footprint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupViews()
    }
    
    fileprivate func setupUser() {
        nameLabel.text = user?.name
        
        if let username = user?.username {
            usernameLabel.text = "@" + username
        }
        
        if let url = user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        if user?.uid == Auth.auth().currentUser?.uid {
            addFriendButton.isHidden = true
            sendMessageButton.isHidden = true
        } else {
            if let uid = user?.uid, UserFriendsData.shared.isFriend(uid) {
                addFriendButton.isHidden = true
                sendMessageButton.isHidden = false
            } else {
                addFriendButton.isHidden = false
                sendMessageButton.isHidden = true
            }
        }
    }

    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-More Filled-50"), style: .plain, target: self, action: #selector(handleOptions))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(collectionView)
        view.addSubview(nameCardView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(profilePhotoImageView)
        view.addSubview(addFriendButton)
        view.addSubview(sendMessageButton)
        
        addFriendButton.topAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: 12).isActive = true
        addFriendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addFriendButton.widthAnchor.constraint(equalToConstant: 256).isActive = true
        addFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        sendMessageButton.topAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: 12).isActive = true
        sendMessageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendMessageButton.widthAnchor.constraint(equalToConstant: 256).isActive = true
        sendMessageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: 64).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        nameCardView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nameCardView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nameCardView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nameCardView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        profilePhotoImageView.topAnchor.constraint(equalTo: nameCardView.topAnchor, constant: 16).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: nameCardView.leftAnchor, constant: 16).isActive = true
        profilePhotoImageView.bottomAnchor.constraint(equalTo: nameCardView.bottomAnchor, constant: -16).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalTo: profilePhotoImageView.heightAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 20).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
    }
    
    fileprivate func setupCollectionView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadCollectionView), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl!)
    }
    
    @objc fileprivate func reloadCollectionView() {
        footprints.removeAll()
        collectionView.reloadData()
        fetchFootprintsForUser()
        
        refreshControl?.endRefreshing()
    }
    
    fileprivate func fetchFootprintsForUser() {
        guard let targetUser = user else { return }
        
        Database.database().reference().child("footprints").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let objects = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for object in objects {
                guard let uid = object.childSnapshot(forPath: "user").value as? String else { return }
                if targetUser.uid != uid {
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
    
    @objc fileprivate func handleShowFullImage(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let fullscreenPhoto = UIImageView(frame: UIScreen.main.bounds)
        fullscreenPhoto.image = imageView.image
        fullscreenPhoto.backgroundColor = .black
        fullscreenPhoto.contentMode = .scaleAspectFit
        fullscreenPhoto.isUserInteractionEnabled = true
        fullscreenPhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissFullImage)))
        view.addSubview(fullscreenPhoto)
        navigationController?.isNavigationBarHidden = true
        tabBarController?.tabBar.isHidden = true
        
        //        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
        //            fullscreenPhoto.frame = UIScreen.main.bounds
        //            fullscreenPhoto.alpha = 1
        //            fullscreenPhoto.layoutSubviews()
        //        }, completion: { (_) in
        //            self.navigationController?.isNavigationBarHidden = true
        //            self.tabBarController?.tabBar.isHidden = true
        //        })
    }
    
    @objc fileprivate func dismissFullImage(_ sender: UITapGestureRecognizer) {
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc fileprivate func handleAddFriend(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let targetUser = user else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["from": currentUser.uid, "to": targetUser.uid!, "timestamp": timestamp] as [String : Any]
        Database.database().reference().child("pending-friends").childByAutoId().updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async(execute: {
                sender.isEnabled = false
            })
        })
    }
    
    @objc fileprivate func handleSendMessage(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let targetUser = user else { return }
        Database.database().reference().child("user-conversations").child(currentUser.uid).child(targetUser.uid!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            guard let cID = dataSnapshot.value as? String else { return }
            let vc = ChatLogCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
            vc.conversationID = cID
            vc.user = targetUser
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        })
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
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 18)
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
    
    let addFriendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Add Friend", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Request Sent", for: .disabled)
        button.setTitleColor(.lightGray, for: .disabled)
        button.backgroundColor = .white
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        button.addTarget(self, action: #selector(handleAddFriend), for: .touchUpInside)
        return button
    }()
    
    let sendMessageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Send Message", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        return button
    }()

}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return footprints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FootprintOnProfileCell", for: indexPath)
        
        if let cell = cell as? FootprintOnProfileCollectionViewCell {
            cell.footprint = footprints[indexPath.row]
            cell.footprintImageViews.forEach({ (imageView) in
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFullImage)))
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if footprints[indexPath.row].imageURLs == nil {
            return CGSize(width: view.frame.width, height: 120)
        } else {
            return CGSize(width: view.frame.width, height: 210)
        }
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
