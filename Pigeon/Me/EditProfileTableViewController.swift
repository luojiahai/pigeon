//
//  EditProfileTableViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 8/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

protocol EditProfileDelegate {
    func reloadData()
    func handleChangeProfilePhoto(completion: (() -> Void)?)
}

class EditProfileTableViewController: UITableViewController {
    
    var delegate: EditProfileDelegate?
    
    var options = [["Profile Photo", "Name", "Username"], ["Email Address"]]
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        
        observeUserData()
    }
    
    func reloadData() {
        observeUserData()
    }
    
    fileprivate func setupNavigation() {
        navigationItem.title = "Edit Profile"
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.tableFooterView = UIView()
        
        tableView.register(SettingsImageTableViewCell.self, forCellReuseIdentifier: "SettingsImageCell")
        tableView.register(SettingsLabelTableViewCell.self, forCellReuseIdentifier: "SettingsLabelCell")
    }
    
    fileprivate func observeUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("users").child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.user = User(uid: snapshot.key, dictionary)
            }
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }, withCancel: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String?
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                identifier = "SettingsImageCell"
            } else {
                identifier = "SettingsLabelCell"
            }
        } else {
            identifier = "SettingsLabelCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier!, for: indexPath)
        
        if let tableCell = cell as? SettingsImageTableViewCell {
            tableCell.textLabel?.text = options[indexPath.section][indexPath.row]
            if let url = user?.profilePhotoURL {
                tableCell.infoImageView.loadImageUsingCache(with: url, completion: nil)
            }
        }
        if let tableCell = cell as? SettingsLabelTableViewCell {
            if indexPath.row == 1 {
                tableCell.textLabel?.text = options[indexPath.section][indexPath.row]
                tableCell.infoTextLabel.text = user?.name
            } else if indexPath.row == 2 {
                tableCell.textLabel?.text = options[indexPath.section][indexPath.row]
                tableCell.infoTextLabel.text = user?.username
            } else {
                tableCell.textLabel?.text = options[indexPath.section][indexPath.row]
                tableCell.infoTextLabel.text = user?.email
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 80
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                handleChangeProfilePhoto()
            } else if indexPath.row == 1 {
                handleChangeName()
            } else {
                handleChangeUsername()
            }
        }
    }
    
    fileprivate func handleChangeProfilePhoto() {
        delegate?.handleChangeProfilePhoto(completion: {
            self.reloadData()
            self.delegate?.reloadData()
        })
    }
    
    fileprivate func handleChangeName() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let alert = UIAlertController(title: "Change Name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.user?.name
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            if let count = alert?.textFields![0].text?.characters.count, count > 8 {
                let formatAlert = UIAlertController(title: "Error", message: "Name format error\nformat：less than or equal to 8 English characters", preferredStyle: .alert)
                formatAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(formatAlert, animated: true, completion: nil)
                return
            }
            
            let textField = alert?.textFields![0]
            let values: [String: AnyObject] = ["name": textField?.text as AnyObject]
            Database.database().reference().child("users").child(currentUser.uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.user?.name = textField?.text
                    self.tableView.reloadData()
                    self.delegate?.reloadData()
                })
            })
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func handleChangeUsername() {
        let alert = UIAlertController(title: "Change Username", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
