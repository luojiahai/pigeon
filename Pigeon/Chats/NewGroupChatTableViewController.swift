//
//  NewGroupChatTableViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 13/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class NewGroupChatTableViewController: UITableViewController {

    var delegate: NewChatTableViewControllerDelegate?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        
        fetchUsers()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "newChat"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: "NewChatCell")
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatCell", for: indexPath)
        
        if let cell = cell as? NewChatTableViewCell {
            cell.user = users[indexPath.row]
            cell.accessoryType = cell.isSelected ? .checkmark : .none
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

}
