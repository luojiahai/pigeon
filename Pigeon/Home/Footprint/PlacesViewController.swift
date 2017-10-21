//
//  PlacesViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/13.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import GooglePlaces

protocol PlacesDataDelegate {
    func selectPlace(_ place: GMSPlace)
}

class PlacesViewController: UITableViewController {
    
    var delegate: PlacesDataDelegate?
    
    var placesClient: GMSPlacesClient!
    var likeHoodList: GMSPlaceLikelihoodList?

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    // Setup the layout of the navigation bar
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "Select Place"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    //When cancel button has been touched up
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
//--------------The table of all places that can be chose----------------    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .groupTableViewBackground
        tableView.register(PlacesTableViewCell.self, forCellReuseIdentifier: "PlacesCell")
        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = likeHoodList?.likelihoods.count else { return 0 }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesCell", for: indexPath)
        
        if let cell = cell as? PlacesTableViewCell {
            cell.place = likeHoodList?.likelihoods[indexPath.row].place
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PlacesTableViewCell else { return }
        guard let place = cell.place else { return }
        
        let alert = UIAlertController(title: "Confirm", message: ("Are you sure want to select " + place.name), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.delegate?.selectPlace(place)
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

}
