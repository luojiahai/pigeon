//
//  AddContactsViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class AddContactsViewController: UITableViewController {

    var users = [User]()
    var filteredUsers = [User]()
    
    var searchController: UISearchController!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        fetchUsers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupSearchController()
        setupTableView()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Add Contacts"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(AddContactsTableViewCell.self, forCellReuseIdentifier: "AddContactsCell")
    }
    
    fileprivate func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func fetchUsers() {
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let snapshots = dataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for snapshot in snapshots {
                if currentUser.uid == snapshot.key {
                    continue
                }
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let user = User(uid: snapshot.key, dictionary)
                    self.users.append(user)
                }
            }
            
            Database.database().reference().child("pending-friends").observe(.childAdded, with: { (friendDataSnapshot) in
                guard let friend = friendDataSnapshot.value as? [String : AnyObject] else { return }
                for user in self.users {
                    if (friend["from"] as? String == currentUser.uid && friend["to"] as? String == user.uid) ||
                        (friend["from"] as? String == user.uid &&
                            friend["to"] as? String == currentUser.uid) {
                        user.isSent = true
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    @objc fileprivate func handleRequest(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["from": currentUser.uid, "to": users[sender.tag].uid!, "timestamp": timestamp] as [String : Any]
        Database.database().reference().child("pending-friends").childByAutoId().updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            AppNotification.shared.sendRequestNotification(sender: currentUser.uid, receiver: self.users[sender.tag].uid!)
            
            DispatchQueue.main.async(execute: {
                sender.isEnabled = false
                sender.setTitle("Sent", for: .disabled)
                sender.backgroundColor = .lightGray
            })
        })
    }

}

extension AddContactsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddContactsCell", for: indexPath)
        
        let user: User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        if let cell = cell as? AddContactsTableViewCell {
            cell.user = user
            if let isSent = user.isSent, isSent {
                cell.requestButton.isEnabled = false
                cell.requestButton.setTitle("Sent", for: .disabled)
                cell.requestButton.backgroundColor = .lightGray
            } else {
                cell.requestButton.isEnabled = true
            }
            cell.requestButton.tag = indexPath.row
            cell.requestButton.addTarget(self, action: #selector(handleRequest), for: .touchUpInside)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            let vc = UserProfileViewController()
            vc.user = filteredUsers[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UserProfileViewController()
            vc.user = users[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension AddContactsViewController: UISearchResultsUpdating {
    
    func filterContent(for searchText: String, scope: String = "All") {
        filteredUsers = users.filter { user in
            return (user.name?.lowercased().contains(searchText.lowercased()))! ||
                (user.username?.lowercased().contains(searchText.lowercased()))!
        }
        
        tableView.reloadData()
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(for: searchController.searchBar.text!)
    }
    
}
