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

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, LoginViewControllerDelegate {
    
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
    
    @objc func reloadData() {
        footprints.removeAll()
        collectionView?.reloadData()
        
        fetchFootprints()
        
        refreshControl?.endRefreshing()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Pigeon"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "presentMap", style: .plain, target: self, action: #selector(handlePresentMap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "postFootprint", style: .plain, target: self, action: #selector(handlePostFootprint))
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
                            let footprint = Footprint()
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
        let vc = UINavigationController(rootViewController: MapViewController())
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return footprints.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FootprintCell", for: indexPath)
        
        if let cell = cell as? FootprintCollectionViewCell {
            cell.footprint = footprints[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 16, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let footprintVC = FootprintViewController()
        footprintVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(footprintVC, animated: true)
    }
    
}
