//
//  FootprintMapViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 18/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FootprintMapViewController: UIViewController {
    
    var manager: CLLocationManager!
    
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    
    var currentUserAnnotation: MKPointAnnotation?
    var targetUserAnnotation: MKPointAnnotation?
    
    var centerMapOnUserLocation: Bool = true
    
    var updateUserLocationTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupLocationManager()
        setupMapView()
    }
    // Setup the layout of the navigation bar
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Map"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "AR", style: .plain, target: self, action: #selector(handleAR))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
    }
    
    // Location Manager is to be informed when updates related to location happen
    fileprivate func setupLocationManager() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    // Setup the layout of the map
    fileprivate func setupMapView() {
        view.addSubview(mapView)
        
        mapView.addSubview(myLocationButton)
        myLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        myLocationButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
        myLocationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        mapView.addSubview(footprintLocationButton)
        footprintLocationButton.bottomAnchor.constraint(equalTo: myLocationButton.topAnchor, constant: -12).isActive = true
        footprintLocationButton.rightAnchor.constraint(equalTo: myLocationButton.rightAnchor).isActive = true
        footprintLocationButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
        footprintLocationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateUserLocation),
            userInfo: nil,
            repeats: true)
    }
    // Update users location when timer tells it to
    @objc func updateUserLocation() {
        if let targetLocation = targetLocation {
            DispatchQueue.main.async {
                if self.targetUserAnnotation == nil {
                    self.targetUserAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.targetUserAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.targetUserAnnotation?.coordinate = targetLocation.coordinate
                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.targetUserAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    })
                }
            }
        }
    }
    // When a began has been touched, center the map to that began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                }
            }
        }
    }
//-----------Funtions related to subviews----------------    
    @objc fileprivate func handleAR() {
        let arVC = ARViewController()
        arVC.delegate = self
        arVC.targetLocation = targetLocation
        let vc = UINavigationController(rootViewController: arVC)
        present(vc, animated: false, completion: nil)
    }
    
    @objc fileprivate func handleFootprintLocation() {
        centerMapOnUserLocation = false
        guard let location = targetLocation else { return }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let myCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(myCoordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc fileprivate func handleMyLocation() {
        centerMapOnUserLocation = false
        guard let location = currentLocation else { return }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let myCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(myCoordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
//-------------All subviews-------------------------------------    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.frame = self.view.frame
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        return mapView
    }()
    
    let footprintLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("fpLocation", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        button.addTarget(self, action: #selector(handleFootprintLocation), for: .touchUpInside)
        return button
    }()
    
    let myLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("myLocation", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = lineColor.cgColor
        button.layer.borderWidth = linePixel
        button.addTarget(self, action: #selector(handleMyLocation), for: .touchUpInside)
        return button
    }()

}

extension FootprintMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first ?? nil
    }
    
}

extension FootprintMapViewController: ARViewControllerDelegate {
    
    func updateLocation() -> CLLocation? {
        return nil
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
