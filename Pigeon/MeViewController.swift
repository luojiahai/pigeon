//
//  MeViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
 
    }


}


// MARK: - MainDataDelegate
// MeViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension MeViewController: LoginViewControllerDelegate {
    func reloadData() {
        //...
    }
}
