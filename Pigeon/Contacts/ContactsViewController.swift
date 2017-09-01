//
//  ContactsViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

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
        
        fetchFriends()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Friends"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "findFriends", style: .plain, target: self, action: #selector(findFriends))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    fileprivate func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: "FriendsCell")
    }
    
    fileprivate func setupSearchController() {
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        definesPresentationContext = true
//        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    fileprivate func fetchFriends() {
        
    }
    
    @objc fileprivate func findFriends() {
        
    }
    
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
        return section == 0 ? nil : "All Friends"
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath)
        
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


// MARK: - LoginViewControllerDelegate
// ContactsViewController is a delegate for LoginViewController. 
// It provides the functionality of cleaning and reloading data in the HomeViewController itself.
extension ContactsViewController: LoginViewControllerDelegate {
    
    @objc func reloadData() {
        contacts.removeAll()
        filteredContacts.removeAll()
        tableView.reloadData()
        
        fetchFriends()
    }
    
}
