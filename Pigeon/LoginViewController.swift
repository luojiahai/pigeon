//
//  LoginViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
    }
    
    @objc fileprivate func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        
        return button
    }()
    
}
