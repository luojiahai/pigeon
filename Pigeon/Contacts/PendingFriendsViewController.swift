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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupTableView()
        
        fetchPendingFriends()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Pending Friends"
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(PendingFriendsTableViewCell.self, forCellReuseIdentifier: "PendingFriendsCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingFriends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingFriendsCell", for: indexPath)
        
        if let cell = cell as? PendingFriendsTableViewCell {
            cell.user = pendingFriends[indexPath.row]
            if let isApproved = cell.user?.isApproved, isApproved {
                cell.approveButton.isEnabled = false
                cell.approveButton.setTitle("Approved", for: .disabled)
                cell.approveButton.backgroundColor = .lightGray
            } else {
                cell.approveButton.isEnabled = true
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
    }
    
    fileprivate func fetchPendingFriends() {
        // back-end here
    }
    
    @objc fileprivate func handleApprove(sender: UIButton) {
        // back-end here
    }
    
    fileprivate func sendApproveNotification(sender: String, receiver: String) {
        // notification here
    }

}
