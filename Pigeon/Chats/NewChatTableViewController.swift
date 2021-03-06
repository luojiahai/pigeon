//
//  NewChatTableViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/4.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

protocol NewChatTableViewControllerDelegate {
    func showChatLog(_ id: String, forUser user: User)
    func showChatLog(_ id: String, forUsers users: [User])
}

class NewChatTableViewController: UITableViewController {
    
    var delegate: NewChatTableViewControllerDelegate?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        
        fetchUsers()
    }
    // Setup the layout of the navigation bar
    fileprivate func setupNavigation() {
        //        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        //
        //        navigationController?.navigationBar.barTintColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        //        navigationController?.navigationBar.tintColor = .white
        //        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "newChat"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
    }
    // table
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: "NewChatCell")
        tableView.tableFooterView = UIView()
    }
    
    // Fetch all the users(friends) that can be target user in a new chat
    fileprivate func fetchUsers() {
        var friendIds = [String]()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("user-friends").child(currentUser.uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for snapshot in snapshots {
                friendIds.append(snapshot.key)
            }
            
            var uids = [String]()
            
            Database.database().reference().child("friends").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let friends = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for id in friendIds {
                    for friend in friends {
                        if id == friend.key {
                            if let uid = friend.childSnapshot(forPath: "from").value as? String, uid != currentUser.uid {
                                uids.append(uid)
                            } else if let uid = friend.childSnapshot(forPath: "to").value as? String, uid != currentUser.uid {
                                uids.append(uid)
                            }
                        }
                    }
                }
            })
            
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let users = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for uid in uids {
                    for user in users {
                        if user.key == uid {
                            guard let dictionary = user.value as? [String: AnyObject] else { return }
                            let friend = User(uid: user.key, dictionary)
                            self.users.append(friend)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    @objc fileprivate func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
//---------------Table of all friends (potential target user)    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatCell", for: indexPath)
        
        if let cell = cell as? NewChatTableViewCell {
            cell.user = users[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    // Select one user as target user and then start the conversation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            guard let currentUser = Auth.auth().currentUser else { return }
            Database.database().reference().child("user-conversations").child(currentUser.uid).child(user.uid!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let cID = dataSnapshot.value as? String else { return }
                self.delegate?.showChatLog(cID, forUser: user)
            })
        }
    }
    
}
