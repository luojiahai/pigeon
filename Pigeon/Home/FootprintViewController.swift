//
//  FootPrintViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit
import MapKit
import Firebase

protocol FootprintViewControllerDelegate {
    func finalizeLike(_ tag: Int)
    func finalizeComment(_ tag: Int)
}

class FootprintViewController: UIViewController, MKMapViewDelegate {
    
    var footprint: Footprint? {
        didSet {
            setupFootprint()
        }
    }
    
    var delegate: FootprintViewControllerDelegate?
    
    var footprintTag: Int?
    
    var likes = [User]()
    
    var comments = [FootprintComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupMapView()
        supportViews()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1000)
    }
    
    fileprivate func setupFootprint() {
        if let url = footprint?.user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        nameLabel.text = footprint?.user?.name
        
        if let username = footprint?.user?.username {
            usernameLabel.text = "@" + username
        }
        
        footprintTextView.text = footprint?.text
        
        if let place = footprint?.place {
            footprintLocationLabel.text = "📍" + place
        }
        
        if let imageURLs = footprint?.imageURLs {
            for index in 0..<3 {
                if index < imageURLs.count {
                    footprintImageViews[index].loadImageUsingCache(with: imageURLs[index])
                    footprintImageViews[index].isHidden = false
                } else {
                    footprintImageViews[index].isHidden = true
                }
            }
        } else {
            footprintImageViews.forEach({ (imageView) in
                imageView.isHidden = true
            })
        }
        
        if let seconds = footprint?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            timeLabel.text = dateFormatter.string(from: timestampDate)
        }
        
        if let likes = footprint?.likes, let currentUser = Auth.auth().currentUser, likes.contains(currentUser.uid) {
            likeButton.isEnabled = false
        } else {
            likeButton.isEnabled = true
        }
        
        var numLikesCommentsText = ""
        if let likes = footprint?.likes {
            numLikesCommentsText += String(likes.count) + " likes "
        }
        if let numComments = footprint?.numComments, numComments > 0 {
            numLikesCommentsText += " " + String(numComments) + " comments"
        }
        numLikesCommentsLabel.text = numLikesCommentsText
        
        fetchLikes()
        fetchComments()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Footprint"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-More Filled-50"), style: .plain, target: self, action: #selector(handleOption))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(mapView)
        scrollView.addSubview(footprintContainerView)
        
        footprintContainerView.topAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        footprintContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footprintContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        guard let text = footprint?.text else { return }
        let estimateHeight = estimateFrameForText(text).height
        var textHeight: CGFloat = 100
        if estimateHeight + 20 <= 100 {
            textHeight = estimateHeight + 20
        } else {
            footprintTextView.isScrollEnabled = true
        }
        if footprint?.imageURLs == nil {
            footprintContainerView.heightAnchor.constraint(equalToConstant: 140 + textHeight).isActive = true
        } else {
            footprintContainerView.heightAnchor.constraint(equalToConstant: 220 + textHeight).isActive = true
        }
        
        footprintContainerView.addSubview(profilePhotoImageView)
        footprintContainerView.addSubview(nameLabel)
        footprintContainerView.addSubview(usernameLabel)
        footprintContainerView.addSubview(verticalLineView)
        footprintContainerView.addSubview(seperatorLineView)
        footprintContainerView.addSubview(footprintTextView)
        footprintContainerView.addSubview(footprintLocationLabel)
        footprintContainerView.addSubview(timeLabel)
        footprintContainerView.addSubview(likeButton)
        footprintContainerView.addSubview(commentButton)
        footprintContainerView.addSubview(numLikesCommentsLabel)
        footprintImageViews.forEach { (imageView) in
            footprintContainerView.addSubview(imageView)
        }
        
        profilePhotoImageView.topAnchor.constraint(equalTo: footprintContainerView.topAnchor, constant: 12).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: footprintContainerView.leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: footprintContainerView.topAnchor, constant: 14).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        
        usernameLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        
        timeLabel.bottomAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 2).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        footprintTextView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 4).isActive = true
        footprintTextView.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 8).isActive = true
        footprintTextView.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor, constant: -12).isActive = true
        footprintTextView.heightAnchor.constraint(equalToConstant: textHeight).isActive = true
        
        var previousRightAnchor: NSLayoutXAxisAnchor?
        footprintImageViews.forEach { (imageView) in
            imageView.topAnchor.constraint(equalTo: footprintTextView.bottomAnchor).isActive = true
            if let prev = previousRightAnchor {
                imageView.leftAnchor.constraint(equalTo: prev, constant: 8).isActive = true
            } else {
                imageView.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 12).isActive = true
            }
            imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
            previousRightAnchor = imageView.rightAnchor
        }
        
        footprintLocationLabel.bottomAnchor.constraint(equalTo: seperatorLineView.topAnchor, constant: -8).isActive = true
        footprintLocationLabel.leftAnchor.constraint(equalTo: footprintContainerView.leftAnchor, constant: 21).isActive = true
        
        verticalLineView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor).isActive = true
        verticalLineView.leftAnchor.constraint(equalTo: profilePhotoImageView.centerXAnchor).isActive = true
        verticalLineView.bottomAnchor.constraint(equalTo: seperatorLineView.topAnchor).isActive = true
        verticalLineView.widthAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        seperatorLineView.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor, constant: -40).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: verticalLineView.leftAnchor).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        likeButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        likeButton.rightAnchor.constraint(equalTo: commentButton.leftAnchor, constant: -8).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        commentButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        commentButton.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor, constant: -18).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        scrollView.addSubview(tableViewSeperatorLineView)
        tableViewSeperatorLineView.topAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        tableViewSeperatorLineView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableViewSeperatorLineView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableViewSeperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        scrollView.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: tableViewSeperatorLineView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        numLikesCommentsLabel.leftAnchor.constraint(equalTo: verticalLineView.leftAnchor).isActive = true
        numLikesCommentsLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor).isActive = true
    }
    
    fileprivate func setupMapView() {
        guard let footprint = footprint else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let coordinate = CLLocationCoordinate2D(latitude: footprint.latitude!, longitude: footprint.longitude!)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func supportViews() {
        footprintImageViews.forEach { (imageView) in
            footprintContainerView.addSubview(imageView)
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowFullImage)))
        }
        
        numLikesCommentsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowLikes)))
        
        profilePhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfileForUser)))
        
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMap)))
    }
    
    fileprivate func fetchLikes() {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            self.footprint?.likes?.forEach({ (uid) in
                guard let dictionary = dataSnapshot.childSnapshot(forPath: uid).value as? [String : AnyObject] else { return }
                let user = User(uid: uid, dictionary)
                self.likes.append(user)
            })
        })
    }
    
    fileprivate func fetchComments() {
        let footprintID = footprint?.footprintID
        Database.database().reference().child("footprints").child(footprintID!).child("comments").observe(.childAdded) { (dataSnapshot) in
            guard let dictionary = dataSnapshot.value as? [String : AnyObject] else { return }
            guard let uid = dictionary["user"] as? String else { return }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (userDataSnapshot) in
                guard let userDictionary = userDataSnapshot.value as? [String: AnyObject] else { return }
                let user = User(uid: uid, userDictionary)
                let comment = FootprintComment(footprintID!, dictionary)
                comment.user = user
                self.comments.append(comment)
                
                DispatchQueue.main.async(execute: {
                    self.comments.sort(by: { (comment1, comment2) -> Bool in
                        return (comment1.timestamp?.int32Value)! < (comment2.timestamp?.int32Value)!
                    })
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    @objc fileprivate func handleOption() {
        let alert = UIAlertController(title: "Option", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
        let footprintID = footprint?.footprintID
        Database.database().reference().child("footprints").child(footprintID!).child("likes").updateChildValues([currentUser.uid: timestamp]) { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                sender.isEnabled = true
                return
            }
            
            DispatchQueue.main.async(execute: {
                if self.footprint?.likes == nil {
                    self.footprint?.likes = [String]()
                }
                self.footprint?.likes?.append(currentUser.uid)
                self.delegate?.finalizeLike(self.footprintTag!)
                self.likes.removeAll()
                self.fetchLikes()
                
                var numLikesCommentsText = ""
                if let likes = self.footprint?.likes {
                    numLikesCommentsText += String(likes.count) + " Likes "
                }
                if let numComments = self.footprint?.numComments, numComments > 0 {
                    numLikesCommentsText += " " + String(numComments) + " Comments"
                }
                self.numLikesCommentsLabel.text = numLikesCommentsText
            })
        }
    }
    
    @objc fileprivate func handleComment(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let footprintID = footprint?.footprintID
        
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
                        if let numComments = self.footprint?.numComments {
                            let newNumComments: UInt = numComments + 1
                            self.footprint?.numComments = newNumComments
                        } else {
                            self.footprint?.numComments = 1
                        }
                        self.delegate?.finalizeComment(sender.tag)
                        
                        var numLikesCommentsText = ""
                        if let likes = self.footprint?.likes {
                            numLikesCommentsText += String(likes.count) + " Likes "
                        }
                        if let numComments = self.footprint?.numComments, numComments > 0 {
                            numLikesCommentsText += " " + String(numComments) + " Comments"
                        }
                        self.numLikesCommentsLabel.text = numLikesCommentsText
                    })
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: view.frame.width - 40, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    @objc fileprivate func handleShowLikes() {
        let vc = UserListTableViewController()
        vc.navigationItem.title = "Likes"
        vc.users = likes
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleShowUserProfileForComment(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let vc = UserProfileViewController()
        vc.user = comments[imageView.tag].user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleShowUserProfileForUser(_ sender: UITapGestureRecognizer) {
        let vc = UserProfileViewController()
        vc.user = footprint?.user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleMap() {
        let mapVC = FootprintMapViewController()
        let coordinate = CLLocationCoordinate2D(latitude: (footprint?.latitude)!, longitude: (footprint?.longitude)!)
        let location = CLLocation(coordinate: coordinate, altitude: (footprint?.altitude)!)
        mapVC.targetLocation = location
        let vc = UINavigationController(rootViewController: mapVC)
        present(vc, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    print("mapView touched")        // bug
                }
            }
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.bounds)
        return scrollView
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/4)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        return mapView
    }()
    
    let footprintContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let profilePhotoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "nameLabel"
        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    let verticalLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let seperatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let footprintTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.text = "footprintTextView"
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.sizeToFit()
        return textView
    }()
    
    let footprintLocationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .darkGray
        label.text = "footprintLocationLabel"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.text = "timeLabel"
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    var footprintImageViews: [CustomImageView] = {
        var imageViews = [CustomImageView]()
        for _ in 0..<3 {
            let imageView = CustomImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = linePixel
            imageView.layer.borderColor = lineColor.cgColor
            imageView.isUserInteractionEnabled = true
            imageViews.append(imageView)
        }
        return imageViews
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icons8-Heart-50"), for: .normal)
        button.setImage(UIImage(named: "icons8-Heart Filled-50"), for: .disabled)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icons8-Comments-50"), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    let numLikesCommentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "numLikesCommentsLabel"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let tableViewSeperatorLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FootprintCommentsTableViewCell.self, forCellReuseIdentifier: "CommentsCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
}

extension FootprintViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        
        if let cell = cell as? FootprintCommentsTableViewCell {
            cell.comment = comments[indexPath.row]
            cell.profilePhotoImageView.tag = indexPath.row
            cell.profilePhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowUserProfileForComment)))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let commentPopoverVC = CommentPopoverViewController()
        commentPopoverVC.comment = comments[indexPath.row]
        commentPopoverVC.modalPresentationStyle = UIModalPresentationStyle.popover
        commentPopoverVC.preferredContentSize = CGSize(width: 256, height: 256)
        commentPopoverVC.popoverPresentationController?.sourceView = view
        commentPopoverVC.popoverPresentationController?.sourceRect = CGRect(x: (view.frame.width - 256)/2, y: (view.frame.height - 256)/2, width: 256, height: 256)
        commentPopoverVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        commentPopoverVC.popoverPresentationController?.delegate = self
        
        present(commentPopoverVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
}

extension FootprintViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}
