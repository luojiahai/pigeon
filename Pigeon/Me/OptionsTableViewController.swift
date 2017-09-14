//
//  OptionsTableViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 15/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

protocol OptionsViewControllerDelegate {
    func handleEditProfile()
    func handleSignOut(completion: (() -> Void)?)
}

class OptionsTableViewController: UITableViewController {

    var delegate: OptionsViewControllerDelegate?
    
    var settingOptions = [["Edit Profile"], ["Log Out"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
    }
    
    fileprivate func setupNavigation() {
        navigationItem.title = "Options"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingOptions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingOptions[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        cell.textLabel?.text = settingOptions[indexPath.section][indexPath.row]
        if cell.textLabel?.text == "Log Out" {
            cell.textLabel?.textColor = .red
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                delegate?.handleEditProfile()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                delegate?.handleSignOut(completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
}
