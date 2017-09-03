//
//  HomeViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        
        view.backgroundColor = .groupTableViewBackground
    }
    
}

// MARK: - LoginViewControllerDelegate
// HomeViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning the data and reloading data in the HomeViewController itself.
extension HomeViewController: LoginViewControllerDelegate {
    
    func reloadData() {
        //...
    }
}
