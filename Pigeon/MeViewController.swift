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
// MeViewController is a MainDataDelegate for LoginViewController. 
// It provides the functionality of cleaning the data in the HomeViewController itself.
extension MeViewController: MainDataDelegate {
    func reloadData() {
        //...
    }
}
