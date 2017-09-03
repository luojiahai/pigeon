//
//  ContactsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class ContactsViewController: UITableViewController {

    var contacts = [User]()
    var filteredContacts = [User]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupSearchController()
        setupTableView()
        setupRefreshControl()
        
        fetchContacts()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "addContacts", style: .plain, target: self, action: #selector(addContacts))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: "ContactsCell")
    }
    
    fileprivate func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    fileprivate func fetchContacts() {
        var friendIds = [String]()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        Database.database().reference().child("users").child(currentUser.uid).child("friends").observeSingleEvent(of: .value) { (dataSnapshot) in
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
                            let contact = User(uid: user.key, dictionary)
                            self.contacts.append(contact)
                        }
                    }
                }
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                })
            })
        }
    }
    
    @objc fileprivate func addContacts() {
        let vc = AddContactsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ContactsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !searchController.isActive {
            return 2
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        if !searchController.isActive && section == 0 {
            return 1
        }
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }
        return section == 0 ? nil : "All Contacts"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact: User
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filteredContacts[indexPath.row]
        } else {
            if !searchController.isActive && indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "Pending Friends"
                return cell
            } else {
                contact = contacts[indexPath.row]
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)
        
        if let cell = cell as? ContactsTableViewCell {
            cell.contact = contact
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return
        } else {
            if !searchController.isActive && indexPath.section == 0 {
                let vc = PendingFriendsViewController()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
    }
    
}

extension ContactsViewController: UISearchResultsUpdating {
    
    func filterContent(for searchText: String, scope: String = "All") {
        filteredContacts = contacts.filter { contact in
            return (contact.name?.lowercased().contains(searchText.lowercased()))! ||
                (contact.username?.lowercased().contains(searchText.lowercased()))!
        }
        
        tableView.reloadData()
    }
    
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContent(for: searchController.searchBar.text!)
    }
    
}


// MARK: - LoginViewControllerDelegate
// ContactsViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension ContactsViewController: LoginViewControllerDelegate {
    
    @objc func reloadData() {
        contacts.removeAll()
        filteredContacts.removeAll()
        tableView.reloadData()
        
        fetchContacts()
    }
    
}
