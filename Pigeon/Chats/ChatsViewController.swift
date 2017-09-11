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
    
    fileprivate func fetchChats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("user-conversations").child(currentUser.uid).observe(.childAdded, with: { (snapshot) in
            let cID = snapshot.value as! String
            Database.database().reference().child("conversations").child(cID).observe(.childAdded, with: { (dataSnapshot) in
                if dataSnapshot.key == "timestamp" { return }
                guard let dictionary = dataSnapshot.value as? [String: AnyObject] else { return }
                let message = Message(dictionary)
                guard let chatTargetID = message.chatTargetID() else { return }
                Database.database().reference().child("users").child(chatTargetID).observeSingleEvent(of: .value, with: { (userDataSnapshot) in
                    guard let userDictionary = userDataSnapshot.value as? [String: AnyObject] else { return }
                    let user = User(uid: chatTargetID, userDictionary)
                    message.targetUser = user
                    self.messagesDictionary[chatTargetID] = message
                    
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
    }
    
    @objc fileprivate func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    @objc fileprivate func handleNewChat() {
        let vc = NewChatTableViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
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
        
        guard let chatTargetID = message.chatTargetID() else { return }
        
        let ref = Database.database().reference().child("users").child(chatTargetID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return}
            let user = User(uid: chatTargetID, dictionary)
            self.showChatLog(for: user)
            self.tableView.isUserInteractionEnabled = true
        })
    }
    
}

extension ChatsViewController: NewChatTableViewControllerDelegate {
    
    func showChatLog(for user: User) {
        let vc = ChatLogCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = user
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
