//
//  PendingFriendsViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class PendingFriendsViewController: UITableViewController {
    
    var pendingFriends = [User]()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        fetchPendingFriends()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    func reloadData() {
        pendingFriends.removeAll()
        tableView.reloadData()
        
        UserFriendsData.shared.pendingFriends.removeAll()
        
        fetchPendingFriends()
    }
//-------------Setup layout of views-------------------------------    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Pending Friends"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(PendingFriendsTableViewCell.self, forCellReuseIdentifier: "PendingFriendsCell")
    }
    
    // Fetch all pending friends of the current user
    fileprivate func fetchPendingFriends() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("pending-friends").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            var pendingSenders = [String]()
            var pendingReceivers = [String]()
            for snapshot in snapshots {
                if snapshot.childSnapshot(forPath: "to").value as? String == currentUser.uid {
                    guard let sender = snapshot.childSnapshot(forPath: "from").value as? String else { return }
                    pendingSenders.append(sender)
                } else if snapshot.childSnapshot(forPath: "from").value as? String == currentUser.uid {
                    guard let receiver = snapshot.childSnapshot(forPath: "to").value as? String else { return }
                    pendingReceivers.append(receiver)
                }
            }
            
            Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                for snapshot in snapshots {
                    if pendingSenders.contains(snapshot.key) {
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let pendingFriend = User(uid: snapshot.key, dictionary)
                            self.pendingFriends.append(pendingFriend)
                        }
                    } else if pendingReceivers.contains(snapshot.key) {
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            let pendingFriend = User(uid: snapshot.key, dictionary)
                            pendingFriend.isSent = true
                            self.pendingFriends.append(pendingFriend)
                        }
                    }
                }
                
                Database.database().reference().child("friends").observeSingleEvent(of: .value, with: { (friendDataSnapshot) in
                    guard let friends = friendDataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                    for friend in friends {
                        for pendingFriend in self.pendingFriends {
                            let from = friend.childSnapshot(forPath: "from").value as? String
                            let to = friend.childSnapshot(forPath: "to").value as? String
                            if from == pendingFriend.uid, to == currentUser.uid {
                                pendingFriend.isApproved = true
                            } else if to == pendingFriend.uid, from == currentUser.uid {
                                pendingFriend.isApproved = true
                            } else {
                                UserFriendsData.shared.pendingFriends.append(pendingFriend)
                            }
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                })
            })
        }
    }
    
    // When the user approves the friend request
    // Update database
    @objc fileprivate func handleApprove(sender: UIButton) {
        // Create new friends
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["from": pendingFriends[sender.tag].uid!, "to": currentUser.uid, "timestamp": timestamp] as [String : Any]
        Database.database().reference().child("friends").childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            // Send notification
            AppNotification.shared.sendApproveNotification(sender: currentUser.uid, receiver: self.pendingFriends[sender.tag].uid!)
            
            // Update the friends list of the current user
            let values = [ref.key: timestamp]
            Database.database().reference().child("user-friends").child(currentUser.uid).updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            })
            // Update the friends list of the target user
            Database.database().reference().child("user-friends").child(self.pendingFriends[sender.tag].uid!).updateChildValues(values, withCompletionBlock: { (err, _) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            })
            // Create (potential) conversations
            let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            Database.database().reference().child("conversations").childByAutoId().updateChildValues(["timestamp": timestamp], withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let toUID = self.pendingFriends[sender.tag].uid!
                let fromUID = currentUser.uid
                let fromValues = [toUID: ref.key]
                let toValues = [fromUID: ref.key]
                Database.database().reference().child("user-conversations").child(fromUID).updateChildValues(fromValues, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                })
                Database.database().reference().child("user-conversations").child(toUID).updateChildValues(toValues, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                })
            })
            
            DispatchQueue.main.async(execute: {
                sender.isEnabled = false
                sender.setTitle("Approved", for: .disabled)
                sender.backgroundColor = .lightGray
            })
        }
    }
    
}
//--------------Table of all pending friends-----------
extension PendingFriendsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingFriends.count
    }
    // Each cell is a pending friend cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendsCell", for: indexPath)
        
        if let cell = cell as? PendingFriendsTableViewCell {
            cell.user = pendingFriends[indexPath.row]
            if let isApproved = cell.user?.isApproved, isApproved {
                cell.approveButton.isEnabled = false
                cell.approveButton.setTitle("Approved", for: .disabled)
                cell.approveButton.backgroundColor = .lightGray
            } else if let isSent = cell.user?.isSent, isSent {
                cell.approveButton.isEnabled = false
                cell.approveButton.setTitle("Sent", for: .disabled)
                cell.approveButton.backgroundColor = .lightGray
            } else {
                cell.approveButton.isEnabled = true
                cell.approveButton.backgroundColor = .black
            }
            cell.approveButton.tag = indexPath.row
            cell.approveButton.addTarget(self, action: #selector(handleApprove), for: .touchUpInside)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UserProfileViewController()
        vc.user = pendingFriends[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
