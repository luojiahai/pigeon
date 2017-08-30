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
        
        view.backgroundColor = .blue
        
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "auth", style: .plain, target: self, action: #selector(auth))
    
        view.addSubview(checkButton)
        checkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        checkButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        checkButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(signOutButton)
        signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: checkButton.topAnchor, constant: 30).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc fileprivate func auth() {
        let loginVC = LoginViewController()
        present(loginVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func check() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Not logged in")
            return
        }
        print(currentUser.uid)
    }
    
    @objc fileprivate func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Check", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(check), for: .touchUpInside)
        return button
    }()
    
    let signOutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()

}

// MARK: - MainDataDelegate
// HomeViewController is a MainDataDelegate for LoginViewController. 
// It provides the functionality of cleaning the data in the HomeViewController itself.
extension HomeViewController: MainDataDelegate {
    func reloadData() {
        //...
    }
}
