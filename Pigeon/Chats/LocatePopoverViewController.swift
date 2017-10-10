//
//  LocatePopoverViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/4.
//  Copyright © 2017 El Root. All rights reserved.
//
import UIKit
import Firebase

protocol LocationSharingStateDelegate {
    func change(state: Bool)
}

class LocatePopoverViewController: UITableViewController {
    
    var delegate: LocationSharingStateDelegate?
    
    var user: User?
    
    var targetUserIsSharing: Bool!
    var currentUserIsSharing: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        targetUserIsSharing = false
        currentUserIsSharing = false
        
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "Switch Cell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Switch Cell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Share My Location"
            cell.selectionStyle = .none
            if let cell = cell as? SwitchTableViewCell {
                cell.switchControl.addTarget(self, action: #selector(switchIsChanged), for: .valueChanged)
                
                guard let currentUser = Auth.auth().currentUser else { break }
                guard let targetUser = user else { break }
                
                cell.switchControl.isEnabled = false
                
                Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    guard let value = dataSnapshot.childSnapshot(forPath: currentUser.uid).childSnapshot(forPath: targetUser.uid!).childSnapshot(forPath: "sharing").value as? Bool else {
                        cell.switchControl.isEnabled = true
                        return
                    }
                    if value == true {
                        cell.switchControl.isOn = true
                        self.currentUserIsSharing = true
                    } else {
                        cell.switchControl.isOn = false
                        self.currentUserIsSharing = false
                    }
                    
                    DispatchQueue.main.async(execute: {
                        cell.switchControl.isEnabled = true
                    })
                })
                
                print("heyyyy")
                
                // Check if targetUser is sharing loc
            Database.database().reference().child("locations").child(targetUser.uid!).child(currentUser.uid).observe(.childChanged, with: { (dataSnapshot) in
                
                //print("yeah" + dataSnapshot.key)
                
                    if dataSnapshot.key == "sharing"  {
                        if let value = dataSnapshot.value as? Bool {
                            if value == true { 
                                self.targetUserIsSharing = true
                                //self.mutualSharing()
                            }
                        }
                    }
                })
                
                
            }
                
        case 1:
            cell.textLabel?.text = "Request Location"
            if let cell = cell as? SwitchTableViewCell {
                cell.switchControl.isHidden = true
            }
        case 2:
            cell.textLabel?.text = "Present Map"
            if let cell = cell as? SwitchTableViewCell {
                cell.switchControl.isHidden = true
            }
        default:
            break
        }
        
        return cell
    }
    
    func mutualSharing() {
        print("In Func mutual sharing ")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:
            requestLocation()
        case 2:
            if (currentUserIsSharing == true && targetUserIsSharing == true) {
                presentMap()

            } else {
                print("I'm: " + currentUserIsSharing.description + " t: " + targetUserIsSharing.description)
                
            }
        default:
            break
        }
    }
    
    @objc fileprivate func switchIsChanged(switchControl: UISwitch) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let targetUser = user else { return }
        
        switchControl.isEnabled = false
        
        if switchControl.isOn {
            currentUserIsSharing = true
            let values = ["sharing": true]
            Database.database().reference().child("locations").child(currentUser.uid).child(targetUser.uid!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    switchControl.isEnabled = true
                }
                
                DispatchQueue.main.async(execute: {
                    switchControl.isEnabled = true
                    self.delegate?.change(state: true)
                })
            })
        } else {
            currentUserIsSharing = false

            let values = ["sharing": false]
            Database.database().reference().child("locations").child(currentUser.uid).child(targetUser.uid!).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    switchControl.isEnabled = true
                }
                
                DispatchQueue.main.async(execute: {
                    switchControl.isEnabled = true
                    self.delegate?.change(state: false)
                })
            })
        }
    }
    
    fileprivate func requestLocation() {
        let alert = UIAlertController(title: "Location Sharing", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func presentMap() {
        let mapVC = MapViewController()
        mapVC.user = user
        let vc = UINavigationController(rootViewController: mapVC)
        present(vc, animated: true, completion: nil)
    }
    
}

class SwitchTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        addSubview(switchControl)
        
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
}
