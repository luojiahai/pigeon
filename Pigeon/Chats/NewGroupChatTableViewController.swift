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
    
    var targetUsers = [User]()
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "createGroup", style: .plain, target: self, action: #selector(handleCreateGroup))
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
    
    @objc fileprivate func handleCreateGroup() {
        dismiss(animated: true) {
            guard let currentUser = Auth.auth().currentUser else { return }
            let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            Database.database().reference().child("conversations").childByAutoId().updateChildValues(["owner": currentUser.uid, "timestamp": timestamp], withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    return
                }
                
                ref.child("members").updateChildValues([currentUser.uid: 1], withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        return
                    }
                })
                
                Database.database().reference().child("user-conversations").child(currentUser.uid).child("groups").updateChildValues([ref.key: timestamp], withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        return
                    }
                })
                
                self.targetUsers.forEach({ (targetUser) in
                    ref.child("members").updateChildValues([targetUser.uid!: 1], withCompletionBlock: { (error, ref) in
                        if let error = error {
                            let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            return
                        }
                    })
                    
                    Database.database().reference().child("user-conversations").child(targetUser.uid!).child("groups").updateChildValues([ref.key: timestamp], withCompletionBlock: { (error, ref) in
                        if let error = error {
                            let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            return
                        }
                    })
                })
                
                Database.database().reference().child("conversations").child(ref.key).childByAutoId().updateChildValues(["text": "I created a group.", "fromUID": currentUser.uid, "timestamp": timestamp]) { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                }
                
                self.delegate?.showChatLog(ref.key, forUsers: self.targetUsers)
            })
        }
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
        if let cell = tableView.cellForRow(at: indexPath) as? NewChatTableViewCell {
            targetUsers.append(cell.user!)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        if let cell = tableView.cellForRow(at: indexPath) as? NewChatTableViewCell {
            targetUsers = targetUsers.filter() { $0 != cell.user }
        }
    }

}
