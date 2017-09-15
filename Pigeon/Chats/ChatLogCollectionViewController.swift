//
//  ChatLogCollectionViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/4.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class ChatLogCollectionViewController: UICollectionViewController {
    
    var manager: CLLocationManager!
    
    var messages = [Message]()
    
    let locatePopoverVC = LocatePopoverViewController()
    
    var conversationID: String? {
        didSet {
            observeMessages()
        }
    }
    
    var users: [User]? {
        didSet {
            navigationItem.title = "Group"
        }
    }
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupCollectionView()
        setupInputComponents()
        setupKeyboardObservers()
        setupLocationManager()
        setupLocatePopoverVC()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        manager.stopUpdatingLocation()
    }
    
    fileprivate func setupNavigation() {
        if user != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-Map Pinpoint Filled-50"), style: .plain, target: self, action: #selector(handleLocate))
        } else if users != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icons8-Info Filled-50"), style: .plain, target: self, action: #selector(handleShowMembers))
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    fileprivate func setupCollectionView() {
        collectionView?.backgroundColor = .groupTableViewBackground
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCollectionViewCell.self, forCellWithReuseIdentifier: "ChatLogCell")
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    fileprivate func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = lineColor
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
    }
    
    fileprivate func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupLocationManager() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    fileprivate func setupLocatePopoverVC() {
        locatePopoverVC.delegate = self
        locatePopoverVC.user = user
        locatePopoverVC.modalPresentationStyle = UIModalPresentationStyle.popover
        locatePopoverVC.preferredContentSize = CGSize(width: 250, height: 44 * locatePopoverVC.tableView.numberOfRows(inSection: 0))
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let targetUser = user else { return }
        
        Database.database().reference().child("locations").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            guard let value = dataSnapshot.childSnapshot(forPath: currentUser.uid).childSnapshot(forPath: targetUser.uid!).childSnapshot(forPath: "sharing").value as? Bool else {
                return
            }
            if value {
                self.change(state: true)
            } else {
                self.change(state: false)
            }
        })
    }
    
    fileprivate func observeMessages() {
        Database.database().reference().child("conversations").child(conversationID!).observe(.childAdded, with: { (snapshot) in
            if snapshot.key == "timestamp" || snapshot.key == "members" || snapshot.key == "owner" { return }
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let message = Message(self.conversationID!, dictionary)
            
            self.messages.append(message)
            
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
                
                // Show the messege bubbles from the latest ones (bottom)
                self.scrollToBottom(animated: false)
            })
        })
    }
    
    fileprivate func scrollToBottom(animated: Bool) {
        let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: animated)  
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatLogCell", for: indexPath)
        
        if let collectionCell = cell as? ChatLogCollectionViewCell {
            let message = messages[indexPath.item]
            setupCell(collectionCell, message)
        }
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func setupCell(_ cell: ChatLogCollectionViewCell, _ message: Message) {
        if let targetUser = user {
            if let url = targetUser.profilePhotoURL {
                cell.profilePhotoImageView.loadImageUsingCache(with: url, completion: nil)
                cell.nameLabel.text = targetUser.name
            }
        } else if let targetUsers = users {
            for targetUser in targetUsers {
                if targetUser.uid == message.fromUID {
                    if let url = targetUser.profilePhotoURL {
                        cell.profilePhotoImageView.loadImageUsingCache(with: url, completion: nil)
                        cell.nameLabel .text = targetUser.name
                    }
                    break
                }
            }
        }
        
        cell.textView.text = message.text
        
        cell.bubbleViewRightAnchor?.isActive = false
        cell.bubbleViewLeftAnchor?.isActive = false
        
        if message.fromUID == Auth.auth().currentUser?.uid {
            //outgoing
            cell.profilePhotoImageView.isHidden = true
            cell.nameLabel.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //incoming
            cell.profilePhotoImageView.isHidden = false
            cell.nameLabel.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
    }
    
    @objc fileprivate func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
 
        let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {self.view.layoutIfNeeded()}, completion: { (completed) in
            if isKeyboardShowing && self.messages.count > 0 {
                // Move the msg bubbles in the bottom to the top of textField and keyboard
                self.scrollToBottom(animated: false)
            }
        })
        
    }
    
    @objc fileprivate func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc fileprivate func handleSend() {
        if let text = inputTextField.text, text != "" {
            sendButton.isEnabled = false
            
            if let targetUser = user {
                let fromUID = Auth.auth().currentUser!.uid
                let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                let values = ["text": text, "fromUID": fromUID, "timestamp": timestamp] as [String : Any]
                
                Database.database().reference().child("conversations").child(conversationID!).childByAutoId().updateChildValues(values) { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.sendButton.isEnabled = true
                        return
                    }
                    
                    self.sendMessageNotification(sender: fromUID, receiver: targetUser.uid!)
                    
                    self.inputTextField.text = nil
                    
                    DispatchQueue.main.async(execute: {
                        self.sendButton.isEnabled = true
                    })
                }
            } else if let targetUsers = users {
                let fromUID = Auth.auth().currentUser!.uid
                let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                let values = ["text": text, "fromUID": fromUID, "timestamp": timestamp] as [String : Any]
                
                Database.database().reference().child("conversations").child(conversationID!).childByAutoId().updateChildValues(values) { (error, ref) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.sendButton.isEnabled = true
                        return
                    }
                    
                    self.inputTextField.text = nil
                    
                    DispatchQueue.main.async(execute: {
                        self.sendButton.isEnabled = true
                    })
                }
            }
        }
    }
    
    fileprivate func sendMessageNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonObject: [String: Any] = [
                "app_id": "eb1565de-1624-4ab0-8392-ff39800489d2",
                "filters": [
                    [
                        "field": "tag",
                        "key": "uid",
                        "relation": "=",
                        "value": receiver
                    ]
                ],
                "contents": [
                    "en": "[\(String(describing: username))]: You've got a new message."
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
    
    @objc fileprivate func handleLocate(_ sender: UIBarButtonItem) {
        //        guard let currentUser = Auth.auth().currentUser else { return }
        //        guard let targetUserUID = user?.uid else { return }
        //
        //        Database.database().reference().child("locations").child(targetUserUID).observe(.childChanged) { (dataSnapshot) in
        //            print("OK")
        //            print(dataSnapshot)
        //        }
        
        locatePopoverVC.popoverPresentationController?.delegate = self
        locatePopoverVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        locatePopoverVC.popoverPresentationController?.permittedArrowDirections = .any
        
        present(locatePopoverVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleShowMembers() {
        let vc = UserListTableViewController()
        vc.navigationItem.title = "Members"
        vc.users = users
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleShowInfo() {
        let alert = UIAlertController(title: "Show Info", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = ""
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.setTitle("Sending", for: .disabled)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
}

extension ChatLogCollectionViewController: LocationSharingStateDelegate {
    
    func change(state: Bool) {
        if state {
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
    }
    
}

extension ChatLogCollectionViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let targetUser = user else { return }
        
        guard let latitude: Double = locations.first?.coordinate.latitude else { return }
        guard let longitude: Double = locations.first?.coordinate.longitude else { return }
        guard let altitude: Double = locations.first?.altitude else { return }
        let values = ["latitude": latitude, "longitude": longitude, "altitude": altitude]
        Database.database().reference().child("locations").child(currentUser.uid).child(targetUser.uid!).child("location").updateChildValues(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
}

extension ChatLogCollectionViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension ChatLogCollectionViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
}

extension ChatLogCollectionViewController: UICollectionViewDelegateFlowLayout {

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get estimated height somehow????
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 38
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
}


