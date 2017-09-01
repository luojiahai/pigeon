//
//  AddContactsViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 1/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class AddContactsViewController: UITableViewController, UISearchResultsUpdating {

    var users = [User]()
    var filteredUsers = [User]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupSearchController()
        setupTableView()
        
        fetchUsers()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Add Contacts"
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
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func fetchUsers() {
        // back-end here
    }
    
    @objc fileprivate func handleRequest(sender: UIButton) {
        // back-end here
    }
    
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
            if let isPending = user.isPending, isPending {
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
    }
    
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
    
    fileprivate func sendRequestNotification(sender: String, receiver: String) {
        // notification here
    }

}
