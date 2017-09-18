//
//  HomeViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class HomeViewController: UICollectionViewController {
    
    var footprints = [Footprint]()
    
    var timer: Timer?
    
    var refreshControl: UIRefreshControl?
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        fetchFootprints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupCollectionView()
        setupRefreshControl()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Pigeon"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-Map Marker Filled-50"), style: .plain, target: self, action: #selector(handlePresentMap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-Cat Footprint Filled-50"), style: .plain, target: self, action: #selector(handlePostFootprint))
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refreshControl!)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .groupTableViewBackground
        collectionView?.register(FootprintCollectionViewCell.self, forCellWithReuseIdentifier: "FootprintCell")
        collectionView?.alwaysBounceVertical = true
    }
    
    fileprivate func fetchFootprints() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("user-friends").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            var friendIds = [String]()
            for snapshot in snapshots {
                friendIds.append(snapshot.key)
            }
            
            Database.database().reference().child("friends").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let friends = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                var uids = [String]()
                for friendId in friendIds {
                    for friend in friends {
                        if friendId == friend.key {
                            if let uid = friend.childSnapshot(forPath: "from").value as? String, uid != currentUser.uid {
                                uids.append(uid)
                            } else if let uid = friend.childSnapshot(forPath: "to").value as? String, uid != currentUser.uid {
                                uids.append(uid)
                            }
                        }
                    }
                }
                
                Database.database().reference().child("footprints").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { (dataSnapshot) in
                    guard let objects = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    for object in objects {
                        guard let uid = object.childSnapshot(forPath: "user").value as? String else { return }
                        if !uids.contains(uid) && currentUser.uid != uid {
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
                            guard let location = object.childSnapshot(forPath: "location").value as? [String: AnyObject] else { return }
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
                                self.footprints.sort(by: { (footprint1, footprint2) -> Bool in
                                    return (footprint1.timestamp?.int32Value)! > (footprint2.timestamp?.int32Value)!
                                })
                                self.timer?.invalidate()
                                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadCollection), userInfo: nil, repeats: false)
                            })
                        })
                    }
                }
            })
        }
    }
    
    @objc fileprivate func handleReloadCollection() {
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    @objc fileprivate func handlePresentMap() {
        let mapVC = MapViewController()
        mapVC.footprints = footprints
        let vc = UINavigationController(rootViewController: mapVC)
        navigationItem.leftBarButtonItem?.isEnabled = false
        present(vc, animated: true) {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    @objc fileprivate func handlePostFootprint() {
        let vc = UINavigationController(rootViewController: PostFootprintViewController())
        navigationItem.rightBarButtonItem?.isEnabled = false
        present(vc, animated: true) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
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
    
    @objc fileprivate func handleLike(_ sender: UIButton) {
        sender.isEnabled = false
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let footprintID = footprints[sender.tag].footprintID
        Database.database().reference().child("footprints").child(footprintID!).child("likes").updateChildValues([currentUser.uid: timestamp]) { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                sender.isEnabled = true
                return
            }
            
            DispatchQueue.main.async(execute: {
                if self.footprints[sender.tag].likes == nil {
                    self.footprints[sender.tag].likes = [String]()
                }
                self.footprints[sender.tag].likes?.append(currentUser.uid)
                self.finalizeLike(sender.tag)
            })
        }
    }
    
    @objc fileprivate func handleComment(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let footprintID = footprints[sender.tag].footprintID
       
        let alert = UIAlertController(title: "Comment", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            if let text = alert?.textFields![0].text, text != "" {
                let values = ["text": text, "user": currentUser.uid, "timestamp": timestamp] as [String : Any]
                Database.database().reference().child("footprints").child(footprintID!).child("comments").childByAutoId().updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        if let numComments = self.footprints[sender.tag].numComments {
                            let newNumComments: UInt = numComments + 1
                            self.footprints[sender.tag].numComments = newNumComments
                        } else {
                            self.footprints[sender.tag].numComments = 1
                        }
                        self.finalizeComment(sender.tag)
                    })
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleShowUserProfile(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let vc = UserProfileViewController()
        vc.user = footprints[imageView.tag].user
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return footprints.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FootprintCell", for: indexPath)
        
        if let cell = cell as? FootprintCollectionViewCell {
            cell.footprint = footprints[indexPath.row]
            cell.footprintImageViews.forEach({ (imageView) in
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFullImage)))
            })
            cell.profilePhotoImageView.tag = indexPath.row
            cell.profilePhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfile)))
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
            cell.commentButton.tag = indexPath.row
            cell.commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
            if let likes = footprints[indexPath.row].likes, let currentUser = Auth.auth().currentUser, likes.contains(currentUser.uid) {
                cell.likeButton.isEnabled = false
            } else {
                cell.likeButton.isEnabled = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if footprints[indexPath.row].imageURLs == nil {
            return CGSize(width: view.frame.width, height: 200)
        } else {
            return CGSize(width: view.frame.width, height: 280)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let footprintVC = FootprintViewController()
        footprintVC.delegate = self
        footprintVC.footprintTag = indexPath.row
        footprintVC.footprint = footprints[indexPath.row]
        footprintVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(footprintVC, animated: true)
    }
    
}

extension HomeViewController: LoginViewControllerDelegate {
    
    @objc func reloadData() {
        footprints.removeAll()
        collectionView?.reloadData()
        
        fetchFootprints()
        
        refreshControl?.endRefreshing()
    }
    
}

extension HomeViewController: FootprintViewControllerDelegate {
    
    func finalizeLike(_ tag: Int) {
        if let cell = collectionView?.cellForItem(at: IndexPath(row: tag, section: 0)) as? FootprintCollectionViewCell {
            cell.likeButton.isEnabled = false
            
            var numLikesCommentsText = ""
            if let likes = footprints[tag].likes {
                numLikesCommentsText += String(likes.count) + " likes "
            }
            if let numComments = footprints[tag].numComments, numComments > 0 {
                numLikesCommentsText += " " + String(numComments) + " comments"
            }
            cell.numLikesCommentsLabel.text = numLikesCommentsText
        }
    }
    
    func finalizeComment(_ tag: Int) {
        if let cell = collectionView?.cellForItem(at: IndexPath(row: tag, section: 0)) as? FootprintCollectionViewCell {
            var numLikesCommentsText = ""
            if let likes = footprints[tag].likes {
                numLikesCommentsText += String(likes.count) + " likes "
            }
            if let numComments = footprints[tag].numComments, numComments > 0 {
                numLikesCommentsText += " " + String(numComments) + " comments"
            }
            cell.numLikesCommentsLabel.text = numLikesCommentsText
        }
    }
    
}
