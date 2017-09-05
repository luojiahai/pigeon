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
    func showChatLog(for user: User)
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
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: "NewChatCell")
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func fetchUsers() {
        var friendshipIds = [String]()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").child(currentUser.uid).child("friendships").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for snapshot in snapshots {
                friendshipIds.append(snapshot.key)
            }
            
            var uids = [String]()
            
            Database.database().reference().child("friendships").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let friendships = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for id in friendshipIds {
                    for friendship in friendships {
                        if id == friendship.key {
                            if let uid = friendship.childSnapshot(forPath: "from").value as? String, uid != currentUser.uid {
                                uids.append(uid)
                            } else if let uid = friendship.childSnapshot(forPath: "to").value as? String, uid != currentUser.uid {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.delegate?.showChatLog(for: user)
        }
    }
    
}
