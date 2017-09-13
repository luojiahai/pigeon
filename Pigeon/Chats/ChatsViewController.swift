//
//  ChatsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var timer: Timer?
    
    let newChatPopoverVC = NewChatPopoverViewController()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        fetchChats()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        //        setupRefreshControl()
        setupNewChatPopoverVC()
    }
    
    fileprivate func setupNavigation() {
        //        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        //
        //        navigationController?.navigationBar.barTintColor = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        //        navigationController?.navigationBar.tintColor = .white
        //        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Chats"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "newChat", style: .plain, target: self, action: #selector(handleNewChat))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadData))
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: "ChatsCell")
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    fileprivate func setupNewChatPopoverVC() {
        newChatPopoverVC.chatsVC = self
        newChatPopoverVC.modalPresentationStyle = UIModalPresentationStyle.popover
        newChatPopoverVC.preferredContentSize = CGSize(width: 165, height: 44 * newChatPopoverVC.tableView.numberOfRows(inSection: 0))
    }
    
    fileprivate func fetchChats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("user-conversations").child(currentUser.uid).child("groups").observe(.childAdded, with: { (snapshot) in
            let cID = snapshot.key
            Database.database().reference().child("conversations").child(cID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let dictionary = dataSnapshot.childSnapshot(forPath: "members").value as? [String: AnyObject] else { return }
                let members = Array(dictionary.keys)
                
                Database.database().reference().child("conversations").child(cID).observe(.childAdded, with: { (dataSnapshot) in
                    if dataSnapshot.key == "timestamp" || dataSnapshot.key == "members" || dataSnapshot.key == "owner" { return }
                    guard let dictionary = dataSnapshot.value as? [String: AnyObject] else { return }
                    let message = Message(cID, dictionary)
                    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (userDataSnapshot) in
                        guard let users = userDataSnapshot.children.allObjects as? [DataSnapshot] else { return }
                        for user in users {
                            let uid = user.key
                            if members.contains(uid) {
                                guard let userDictionary = user.value as? [String: AnyObject] else { return }
                                let user = User(uid: uid, userDictionary)
                                if message.targetUsers == nil {
                                    message.targetUsers = [User]()
                                }
                                message.targetUsers?.append(user)
                                self.messagesDictionary[cID] = message
                            }
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages.sort(by: { (message1, message2) -> Bool in
                                return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
                            })
                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        })
                    })
                })
            })
        })
        
        Database.database().reference().child("user-conversations").child(currentUser.uid).observe(.childAdded, with: { (snapshot) in
            if snapshot.key == "groups" { return }
            guard let cID = snapshot.value as? String else { return }
            Database.database().reference().child("conversations").child(cID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                Database.database().reference().child("conversations").child(cID).observe(.childAdded, with: { (dataSnapshot) in
                    if dataSnapshot.key == "timestamp" || dataSnapshot.key == "members" || dataSnapshot.key == "owner" { return }
                    guard let dictionary = dataSnapshot.value as? [String: AnyObject] else { return }
                    let message = Message(cID, dictionary)
                    let chatTargetID = snapshot.key
                    Database.database().reference().child("users").child(chatTargetID).observeSingleEvent(of: .value, with: { (userDataSnapshot) in
                        guard let userDictionary = userDataSnapshot.value as? [String: AnyObject] else { return }
                        let user = User(uid: chatTargetID, userDictionary)
                        message.targetUser = user
                        self.messagesDictionary[cID] = message
                        
                        DispatchQueue.main.async(execute: {
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages.sort(by: { (message1, message2) -> Bool in
                                return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
                            })
                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        })
                    })
                })
            })
        })
    }
    
    @objc fileprivate func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    @objc fileprivate func handleNewChat() {
        newChatPopoverVC.popoverPresentationController?.delegate = self
        newChatPopoverVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        newChatPopoverVC.popoverPresentationController?.permittedArrowDirections = .any
        
        present(newChatPopoverVC, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath)
        
        if let cell = cell as? ChatsTableViewCell {
            cell.message = messages[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        
        let message = messages[indexPath.row]
        
        if let targetUser = message.targetUser {
            self.showChatLog(message.conversationID!, forUser: targetUser)
            self.tableView.isUserInteractionEnabled = true
        } else if let targetUsers = message.targetUsers {
            self.showChatLog(message.conversationID!, forUsers: targetUsers)
            self.tableView.isUserInteractionEnabled = true
        }
        
        
    }
    
}

extension ChatsViewController: NewChatTableViewControllerDelegate {
    
    func showChatLog(_ id: String, forUser user: User) {
        let vc = ChatLogCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.conversationID = id
        vc.user = user
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatLog(_ id: String, forUsers users: [User]) {
        let vc = ChatLogCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.conversationID = id
        vc.users = users
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ChatsViewController: LoginViewControllerDelegate {
    
    @objc func reloadData() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        fetchChats()
    }
    
}

extension ChatsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}
