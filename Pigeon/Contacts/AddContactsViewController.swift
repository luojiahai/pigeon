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
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }
        
        Database.database().reference().child("pending-contacts").observeSingleEvent(of: .value, with: { (friendshipDataSnapshot) in
            guard let friendships = friendshipDataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for friendship in friendships {
                for user in self.users {
                    if (friendship.childSnapshot(forPath: "from").value as? String == currentUser.uid && friendship.childSnapshot(forPath: "to").value as? String == user.uid) ||
                        (friendship.childSnapshot(forPath: "from").value as? String == user.uid &&
                            friendship.childSnapshot(forPath: "to").value as? String == currentUser.uid) {
                        user.isPending = true
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
    
    @objc fileprivate func handleRequest(sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["from": currentUser.uid, "to": users[sender.tag].uid!, "timestamp": timestamp] as [String : Any]
        Database.database().reference().child("pending-contacts").childByAutoId().updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.sendRequestNotification(sender: currentUser.uid, receiver: self.users[sender.tag].uid!)
            
            DispatchQueue.main.async(execute: {
                sender.isEnabled = false
                sender.setTitle("Sent", for: .disabled)
                sender.backgroundColor = .lightGray
            })
        })
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
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic ZTliOGU2ZTItNzllYS00MDA4LWI1ZGQtYmI5YWU1ZGNjMWI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonObject: [String: Any] = [
                "app_id": "e7881ec9-db20-4f40-b21b-791a5efb058f",
                "filters": [
                    [
                        "field": "tag",
                        "key": "uid",
                        "relation": "=",
                        "value": receiver
                    ]
                ],
                "contents": [
                    "en": "[\(String(describing: username))]: You've got a new friend request."
                ]
            ]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error JSON")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
        }
    }

}
