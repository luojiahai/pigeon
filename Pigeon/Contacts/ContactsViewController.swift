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
    
    var pendingFriendsVC = PendingFriendsViewController(style: .plain)
    
    var searchController: UISearchController!
    
    var timer: Timer?
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        fetchContacts()
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
        //        setupRefreshControl()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Contacts"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-Add User Male Filled-50"), style: .plain, target: self, action: #selector(addContacts))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadData))
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
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    fileprivate func fetchContacts() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("user-friends").child(currentUser.uid).observe(.childAdded) { (dataSnapshot) in
            Database.database().reference().child("friends").child(dataSnapshot.key).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let dictionary = dataSnapshot.value as? [String: AnyObject] else { return }
                var targetUser: String?
                if let uid = dictionary["from"] as? String, uid != currentUser.uid {
                    targetUser = uid
                } else if let uid = dictionary["to"] as? String, uid != currentUser.uid {
                    targetUser = uid
                }
                
                Database.database().reference().child("users").child(targetUser!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    guard let dictionary = dataSnapshot.value as? [String: AnyObject] else { return }
                    let contact = User(uid: dataSnapshot.key, dictionary)
                    self.contacts.append(contact)
                    UserFriendsData.shared.contacts.append(contact)
                    
                    DispatchQueue.main.async(execute: {
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    })
                })
            })
        }
    }
    
    @objc fileprivate func handleReloadTable() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    @objc fileprivate func addContacts() {
        let vc = AddContactsViewController(style: .plain)
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
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
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
            let vc = UserProfileViewController()
            vc.user = filteredContacts[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if !searchController.isActive && indexPath.section == 0 {
                pendingFriendsVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(pendingFriendsVC, animated: true)
                return
            } else {
                let vc = UserProfileViewController()
                vc.user = contacts[indexPath.row]
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
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
        UserFriendsData.shared.removeAll()
        
        contacts.removeAll()
        filteredContacts.removeAll()
        tableView.reloadData()
        
        pendingFriendsVC.reloadData()
        
        fetchContacts()
    }
    
}
