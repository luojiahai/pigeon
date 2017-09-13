//
//  PlacesViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/13.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesViewController: UITableViewController {
    
    var placesClient: GMSPlacesClient!
    var likeHoodList: GMSPlaceLikelihoodList?
    var selectedPlace: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        nearbyPlaces()
        view.backgroundColor = .white
        setupNavigation()
        setupTableView()
    }
    
    func nearbyPlaces() {
        // init placesClient
        placesClient = GMSPlacesClient.shared()
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // Get likeHoodList
            if let placeLikelihoodList = placeLikelihoodList {
                self.likeHoodList = placeLikelihoodList
                self.tableView.reloadData()
            }
        })
    }
    
    
    fileprivate func setupNavigation() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "SelectPlace"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(handleConfirm))
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleConfirm() {
        let alert: UIAlertController
        if let place = selectedPlace {
            alert = UIAlertController(title: "Selected", message: ("You just selected " + place.name), preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "No Selection", message: "You must select a place", preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
//        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(PlacesTableViewCell.self, forCellReuseIdentifier: "PlacesCell")
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCell", for: indexPath)
        let place = likeHoodList?.likelihoods[indexPath.row].place //this is a GMSPlace object
        cell.textLabel?.text = place?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedPlace = (likeHoodList?.likelihoods[indexPath.row].place)!
    }

}
