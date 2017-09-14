//
//  FootPrintViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017年 El Root. All rights reserved.
//

import UIKit
import MapKit

class FootprintViewController: UIViewController, MKMapViewDelegate {
    
    var footprint: Footprint? {
        didSet {
            setupFootprint()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupMapView()
    }
    
    fileprivate func setupFootprint() {
        if let url = footprint?.user?.profilePhotoURL {
            profilePhotoImageView.loadImageUsingCache(with: url)
        }
        
        nameLabel.text = footprint?.user?.name
        
        usernameLabel.text = "@" + (footprint?.user?.username)!
        
        footprintTextView.text = footprint?.text
        
        footprintLocationLabel.text = "📍" + (footprint?.place)!
        
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
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Footprint"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "option", style: .plain, target: self, action: #selector(handleOption))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(mapView)
        view.addSubview(footprintContainerView)
        
        footprintContainerView.topAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        footprintContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footprintContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        if footprint?.imageURLs == nil {
            footprintContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        } else {
            footprintContainerView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        }
        
        footprintContainerView.addSubview(profilePhotoImageView)
        footprintContainerView.addSubview(nameLabel)
        footprintContainerView.addSubview(usernameLabel)
        footprintContainerView.addSubview(seperatorLineView)
        footprintContainerView.addSubview(footprintTextView)
        footprintContainerView.addSubview(footprintLocationLabel)
        footprintContainerView.addSubview(timeLabel)
        footprintContainerView.addSubview(verticalLineView)
        footprintContainerView.addSubview(likeButton)
        footprintContainerView.addSubview(commentButton)
        
        footprintImageViews.forEach { (imageView) in
            footprintContainerView.addSubview(imageView)
        }
        
        profilePhotoImageView.topAnchor.constraint(equalTo: footprintContainerView.topAnchor, constant: 12).isActive = true
        profilePhotoImageView.leftAnchor.constraint(equalTo: footprintContainerView.leftAnchor, constant: 12).isActive = true
        profilePhotoImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profilePhotoImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: footprintContainerView.topAnchor, constant: 14).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: profilePhotoImageView.rightAnchor, constant: 12).isActive = true
        
        usernameLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 10).isActive = true
        
        timeLabel.bottomAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 2).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        
        footprintTextView.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 4).isActive = true
        footprintTextView.leftAnchor.constraint(equalTo: verticalLineView.rightAnchor, constant: 8).isActive = true
        footprintTextView.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor, constant: -12).isActive = true
        footprintTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
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
        verticalLineView.bottomAnchor.constraint(equalTo: footprintLocationLabel.topAnchor).isActive = true
        verticalLineView.widthAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        seperatorLineView.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor, constant: -40).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: footprintContainerView.leftAnchor, constant: 12).isActive = true
        seperatorLineView.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor, constant: -12).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        likeButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        likeButton.rightAnchor.constraint(equalTo: commentButton.leftAnchor, constant: -8).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        commentButton.topAnchor.constraint(equalTo: seperatorLineView.bottomAnchor).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        commentButton.rightAnchor.constraint(equalTo: footprintContainerView.rightAnchor, constant: -12).isActive = true
        commentButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        view.addSubview(tableViewSeperatorLineView)
        tableViewSeperatorLineView.topAnchor.constraint(equalTo: footprintContainerView.bottomAnchor).isActive = true
        tableViewSeperatorLineView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableViewSeperatorLineView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableViewSeperatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: tableViewSeperatorLineView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func setupMapView() {
        guard let footprint = footprint else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let coordinate = CLLocationCoordinate2D(latitude: footprint.latitude!, longitude: footprint.longitude!)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    @objc fileprivate func handleOption() {
        let alert = UIAlertController(title: "Option", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/4)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
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
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "nameLabel"
        label.sizeToFit()
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "nameLabel"
        label.font = UIFont.systemFont(ofSize: 16)
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
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
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
        label.font = UIFont.systemFont(ofSize: 16)
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
            imageView.contentMode = .scaleAspectFit
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Like", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("Comment", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        return button
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
        tableView.register(CommentsTableViewCell.self, forCellReuseIdentifier: "CommentsCell")
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
}

extension FootprintViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        cell.textLabel?.text = "comment"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}

class CommentsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
