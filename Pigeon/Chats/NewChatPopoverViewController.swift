//
//  NewChatPopoverViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 12/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class NewChatPopoverViewController: UITableViewController {
    
    var chatsVC: ChatsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
//----------------New chat and New group chat-----------------------------------------------
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "New Chat"
        case 1:
            cell.textLabel?.text = "New Group Chat"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true, completion: nil)
        
        switch indexPath.row {
        case 0:
            newChat()
        case 1:
            newGroupChat()
        default:
            break
        }
    }
    
    fileprivate func newChat() {
        let vc = NewChatTableViewController()
        vc.delegate = chatsVC
        chatsVC?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    fileprivate func newGroupChat() {
        let vc = NewGroupChatTableViewController()
        vc.delegate = chatsVC
        chatsVC?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
}

