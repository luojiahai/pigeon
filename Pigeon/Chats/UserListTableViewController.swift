//
//  UserListTableViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 13/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class UserListTableViewController: UITableViewController {

    var users: [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
    }
    // Setup the layout of navigation bar
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
//---------------------Table of users--------------------------------    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(NewChatTableViewCell.self, forCellReuseIdentifier: "NewChatCell")
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users!.count
    }
    // Each user can be selected to have a new chat with
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatCell", for: indexPath)
        
        if let cell = cell as? NewChatTableViewCell {
            cell.user = users?[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    // Go to new chat view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UserProfileViewController()
        vc.user = users?[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}
