//
//  MapViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

protocol ARListener {
    func dismissAR()
}

class MapViewController: UIViewController {
    
    var listener: ARListener?
    
    var manager: CLLocationManager!
    
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    var targetUserLocations: [UserLocation]?
    
    var currentUserAnnotation: MKPointAnnotation?
    var targetUserAnnotation: MKPointAnnotation?
    var targetUserAnnotations: [MKPointAnnotation]?
    
    var centerMapOnUserLocation: Bool = true
    
    var updateUserLocationTimer: Timer?
    
    var conversationID: String?
    var user: User?
    var users: [User]?
    
    var footprints: [Footprint]?
    
    var routeShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupLocationManager()
        setupMapView()
        //        setupLocationSharing()
        renderFootprint()
    }
    
    /*------------------------------- view setup starts here -------------------------------------- */
    @objc fileprivate func handleAnnotationTap(_ gesture: UITapGestureRecognizer) {
        print("Annotation Tapped")
        let marker = gesture.view as? MKMarkerAnnotationView
        let annotation = marker?.annotation
        let vc = FootprintopoverViewController()
        for footprint in footprints! {
            // find the footprint of the annotaiton with footprintID
            if footprint.footprintID == (annotation?.subtitle)! {
                vc.footprint = footprint // pass the footprint
            }
        }
        
        // setup the popover controller
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.preferredContentSize = CGSize(width: 256, height: 256)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.sourceRect = CGRect(x: (view.frame.width - 256)/2, y: (view.frame.height - 256)/2, width: 256, height: 256)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        vc.popoverPresentationController?.delegate = self
        
        present(vc, animated: true, completion: nil)
    }
    
    fileprivate func renderFootprint() {
        if footprints == nil {
            return
        }
        
        // render each footprint
        for footprint in footprints! {
            let coordinate = CLLocationCoordinate2D(latitude: footprint.latitude!, longitude: footprint.longitude!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = footprint.user?.name
            annotation.subtitle = footprint.footprintID
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupLocationSharing()
    }
    
    fileprivate func setupLocationSharing() {
        if user != nil {
            if let currentUser = Auth.auth().currentUser, let targetUser = user {
                Database.database().reference().child("locations").child(targetUser.uid!).child(currentUser.uid).child("location").observe(.value, with: { (dataSnapshot) in
                    guard let dictionary = dataSnapshot.value as? [String: Double] else { return }
                    self.targetLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: dictionary["latitude"]!, longitude: dictionary["longitude"]!), altitude: dictionary["altitude"]!)
                })
            }
        } else if let users = users {
            guard let currentUser = Auth.auth().currentUser else { return }
            guard let groupID = conversationID else { return }
            targetUserLocations = [UserLocation]()
            targetUserAnnotations = [MKPointAnnotation]()
            for targetUser in users {
                if targetUser.uid! == currentUser.uid {
                    continue
                }
                let annotation = MKPointAnnotation()
                annotation.title = targetUser.username
                targetUserAnnotations?.append(annotation)
                mapView.addAnnotation(annotation)
                let userLocation = UserLocation((targetUserAnnotations?.index(of: annotation))!, user: targetUser, location: nil)
                targetUserLocations?.append(userLocation)
            }
            
            guard let targetUserLocations = targetUserLocations else { return }
            for targetUserLocation in targetUserLocations {
                Database.database().reference().child("locations").child("group").child(groupID).child((targetUserLocation.user?.uid)!).child("location").observe(.value, with: { (dataSnapshot) in
                    guard let dictionary = dataSnapshot.value as? [String: Double] else { return }
                    targetUserLocation.location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: dictionary["latitude"]!, longitude: dictionary["longitude"]!), altitude: dictionary["altitude"]!)
                })
            }
        }
    }
    
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
    
    fileprivate func setupLocationManager() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    fileprivate func setupMapView() {
        view.addSubview(mapView)
        
        mapView.addSubview(myLocationButton)
        myLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        myLocationButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        myLocationButton.widthAnchor.constraint(equalToConstant: 128).isActive = true
        myLocationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(updateUserLocation),
            userInfo: nil,
            repeats: true)
    }
    
    func setRoute() {
        if user != nil {
            // get coordinates
            let sourceCoordinate = currentLocation?.coordinate
            let destCoordinate = targetLocation?.coordinate
            
            // create Placemarks
            let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate!)
            let destPlaceMark = MKPlacemark(coordinate: destCoordinate!)
            
            // create MapItems
            let sourceItem = MKMapItem(placemark: sourcePlaceMark)  // POI on map
            let destItem = MKMapItem(placemark: destPlaceMark)
            
            // Name the MapItems
            sourceItem.name = "Source"
            destItem.name = "Destination"
            
            // Create a direction request
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = sourceItem
            directionRequest.destination = destItem
            directionRequest.transportType = MKDirectionsTransportType.walking  // can modify transport type
            let directions = MKDirections(request: directionRequest) // computes directions and travel time
            
            // Find direction and draw route
            directions.calculate(completionHandler: {
                response, error in
                
                // check response
                guard let response = response else {
                    if error != nil {
                        print("Error during calculation of directions")
                    }
                    return
                }
                
                // draw route
                let route = response.routes[0]  // 0 for the fastest route
                self.mapView.add(route.polyline, level: .aboveRoads)
                
                //            // set region
                //            let rect = route.polyline.boundingMapRect
                //            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // return a renderer for rendering polyline of the route
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue  // color of the polyline
        renderer.lineWidth = 5.0
        return renderer
    }
    
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
    
    /*------------------------------- view setup ends here -------------------------------------- */
    
    //action called constantly to update locations
    @objc func updateUserLocation() {
        if let currentLocation = currentLocation {
            DispatchQueue.main.async {
                //                if self.currentUserAnnotation == nil {
                //                    self.currentUserAnnotation = MKPointAnnotation()
                //                    self.mapView.addAnnotation(self.currentUserAnnotation!)
                //                }
                
                //                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                //                    self.currentUserAnnotation?.coordinate = currentLocation.coordinate
                //                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        //                        self.mapView.setCenter(self.currentUserAnnotation!.coordinate, animated: false)
                        self.mapView.setCenter(currentLocation.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    })
                }
            }
        }
        
        if let targetLocation = targetLocation {
            DispatchQueue.main.async {
                if self.targetUserAnnotation == nil {
                    self.targetUserAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.targetUserAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.targetUserAnnotation?.coordinate = targetLocation.coordinate
                }, completion: nil)
            }
        }
        
        if let targetUserAnnotations = targetUserAnnotations {
            DispatchQueue.main.async {
                for annotation in targetUserAnnotations {
                    UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        guard let targetUserLocations = self.targetUserLocations else { return }
                        for targetUserLocation in targetUserLocations {
                            if targetUserLocation.annotationIndex == targetUserAnnotations.index(of: annotation) {
                                if let coordinate = targetUserLocation.location?.coordinate {
                                    annotation.coordinate = coordinate
                                }
                                break
                            }
                        }
                    }, completion: nil)
                }
            }
        }
        
        // set the route from current location to target location
        if currentLocation != nil &&
            targetLocation != nil &&
            !routeShown {
            setRoute()
            routeShown = true
        }
        
    }
    
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
    
    //action when AR mode is on
    @objc fileprivate func handleAR() {
        if users != nil {
            let alert = UIAlertController(title: "AR", message: "Group location sharing in AR is not supported. Feature comming soon...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            let arVC = ARViewController()
            arVC.delegate = self
            listener = arVC
            arVC.targetLocation = targetLocation
            arVC.footprints = footprints
            let vc = UINavigationController(rootViewController: arVC)
            present(vc, animated: false, completion: nil)
        }
    }
    
    //action when my location button is clicked
    @objc fileprivate func handleMyLocation() {
        centerMapOnUserLocation = false
        guard let location = currentLocation else { return }
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let myCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(myCoordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first ?? nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.currentUserAnnotation {  // no more currentUserAnnotation
//                marker.displayPriority = .required
//                marker.glyphImage = UIImage(named: "user")
            } else if pointAnnotation == self.targetUserAnnotation {
                marker.displayPriority = .required
//                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "user")
            } else if users != nil {
                marker.displayPriority = .required
//                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "user")
            } else {
                // footprints
                marker.isEnabled = false  // not touchable
                
                marker.displayPriority = .required
                marker.markerTintColor = .gray
                marker.glyphImage = UIImage(named: "icons8-Cat Footprint Filled-50")
                let gesture = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationTap))
                marker.addGestureRecognizer(gesture)
                
            }
            return marker
        }
        
        return nil
    }
    
}

extension MapViewController: ARViewControllerDelegate {
    
    func updateLocation() -> CLLocation? {
        return targetLocation
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

extension MapViewController: LocationSharingStatusListener {
    
    func dismissMap() {
        if listener != nil {
            self.listener?.dismissAR()
        } else {
            let alert = UIAlertController(title: "Exit From Map", message: "Your friend turned off Location Sharing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

