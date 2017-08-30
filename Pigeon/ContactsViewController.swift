//
//  ContactsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - MainDataDelegate
// ContactsViewController is a MainDataDelegate for LoginViewController. 
// It provides the functionality of cleaning the data in the HomeViewController itself.
extension ContactsViewController: MainDataDelegate {
    func reloadData() {
        //...
    }
}
