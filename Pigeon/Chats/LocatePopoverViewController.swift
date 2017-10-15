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
        
    }
    fileprivate func setupView() {
        view.backgroundColor = .white
        view.addSubview(blurryView)
        setupCenterWindow()
        setupButtons()
    }
    let blurryView: UIVisualEffectView = {
        let blurry = UIVisualEffectView()
        blurry.effect = UIBlurEffect(style: .prominent)
        return blurry
    }()
    
    fileprivate func setupCenterWindow() {
        view.addSubview(centerWindow)
        centerWindow.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerWindow.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        centerWindow.backgroundColor = .red
    }
    fileprivate func setupButtons() {
        view.addSubview(presentMapButton)
        presentMapButton.centerYAnchor.constraint(equalTo: centerWindow.centerYAnchor)
        
        view.addSubview(friendSettingButton)
        view.addSubview(searchChatHistoryButton)
	}
    
    let centerWindow: UIView = {
        let centerWindow = UIView()
        return centerWindow
    }()
    
    let presentMapButton: UIButton = {
        let button = UIButton()
        button.setTitle("Present Image", for: .normal)
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
        button.setTitle("search Chat History", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
}
