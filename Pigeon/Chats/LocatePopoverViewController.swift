//
//  LocatePopoverViewController.swift
//  Pigeon
//
//  Created by Tina Luan on 5/10/17.
//  Copyright © 2017 El Root. All rights reserved.
//
import UIKit
import Firebase

protocol LocationSharingStateDelegate {
    func change(state: Bool)
}

class LocatePopoverViewController: UIViewController {
    
    var delegate: LocationSharingStateDelegate?
    
    var user: User?
    
    var targetUserIsSharing: Bool!
    var currentUserIsSharing: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
	    // targetUserIsSharing = false
	    // currentUserIsSharing = false
        setupButtons()
    }
    fileprivate func setupView() {
        //view.backgroundColor = .blue
        view.addSubview(blurryView)
        //setupCenterWindow()
        //setupButtons()
    }
    let blurryView: UIVisualEffectView = {
        let blurry = UIVisualEffectView()
        blurry.effect = UIBlurEffect(style: .prominent)
        return blurry
    }()
    
    fileprivate func setupCenterWindow() {
        view.addSubview(centerWindow)
        centerWindow.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerWindow.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerWindow.backgroundColor = .red
    }
    fileprivate func setupButtons() {
        view.addSubview(presentMapButton)
        presentMapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        presentMapButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        presentMapButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        presentMapButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        presentMapButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        presentMapButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 85).isActive = true
        
        view.addSubview(friendSettingButton)
        friendSettingButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        friendSettingButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        friendSettingButton.topAnchor.constraint(equalTo: presentMapButton.bottomAnchor).isActive = true
        friendSettingButton.bottomAnchor.constraint(equalTo: friendSettingButton.topAnchor, constant: 85).isActive = true        
        
        view.addSubview(searchChatHistoryButton)
        searchChatHistoryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchChatHistoryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        searchChatHistoryButton.topAnchor.constraint(equalTo: friendSettingButton.bottomAnchor).isActive = true
        searchChatHistoryButton.bottomAnchor.constraint(equalTo: searchChatHistoryButton.topAnchor, constant: 85).isActive = true
	}
    
    let centerWindow: UIView = {
        let centerWindow = UIView()
        return centerWindow
    }()
    
    let presentMapButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Present Map", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    let friendSettingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Friend Setting", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    let searchChatHistoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Search Chat History", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
}
