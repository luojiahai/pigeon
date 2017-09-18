//
//  ARViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/5.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import SceneKit
import MapKit
//import CocoaLumberjack

protocol ARViewControllerDelegate {
    func handleCancel()
}

class ARViewController: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate {
    
    var delegate: ARViewControllerDelegate?
    
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    var targetLocation: CLLocation?
    
    var pinLocationNode: LocationAnnotationNode?
    
    var targetUserAnnotation: MKPointAnnotation?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = true
    
    var centerMapOnUserLocation: Bool = true
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = false
    
    var infoLabel = UILabel()
    
    var updateInfoLabelTimer: Timer?
    
    var adjustNorthByTappingSidesOfScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "AR"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(handleMap))
        
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        sceneLocationView.addSubview(infoLabel)
        
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(ARViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        //        sceneLocationView.orientToTrueNorth = false
        //
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        
        //        // Currently set to coop bookshop unimelb
        //        let pinCoordinate = CLLocationCoordinate2D(latitude: -37.800341, longitude: 144.963835)
        //        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 50)
        //        let pinImage = UIImage(named: "pin")!
        //        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        //        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
        if let targetLocation = targetLocation {
            let pinCoordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: targetLocation.altitude)
            let pinImage = UIImage(named: "pin")!
            pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode!)
        }
        
        view.addSubview(sceneLocationView)
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            view.addSubview(mapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(ARViewController.updateUserLocation),
                userInfo: nil,
                repeats: true)
        }
        
        view.addSubview(debugLabel)
        debugLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        debugLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: false) {
            self.delegate?.handleCancel()
        }
    }
    
    @objc fileprivate func handleMap() {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        if showMapView {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
//                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
//                    let position = self.sceneLocationView.currentScenePosition() {
//                    DDLogDebug("")
//                    DDLogDebug("Fetch current location")
//                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
//                    DDLogDebug("current position: \(position)")
//
//                    let translation = bestEstimate.translatedLocation(to: position)
//
//                    DDLogDebug("translation: \(translation)")
//                    DDLogDebug("translated location: \(currentLocation)")
//                    DDLogDebug("")
//                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    })
                }
                
                if self.displayDebugging {
                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
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
    }
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
                if (mapView == touch.view! ||
                    mapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                } else {
                    
                    let location = touch.location(in: self.view)
                    
                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
                        print("left side of the screen")
                        sceneLocationView.moveSceneHeadingAntiClockwise()
                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
                        print("right side of the screen")
                        sceneLocationView.moveSceneHeadingClockwise()
                    } else {
                        //                        let image = UIImage(named: "pin")!
                        //                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
                        //                        annotationNode.scaleRelativeToDistance = true
                        //                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                    }
                }
            }
        }
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
//        DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
//        DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
        //        DispatchQueue.global(qos: .background)
        
        guard let currentLocation = sceneLocationView.currentLocation() else { return }
        guard let targetLocation = targetLocation else { return }
        let distance = currentLocation.distance(from: targetLocation)
        
        var debugText = String()
        debugText += "target distance: " + String(Int(distance)) + " metres\n"
        debugText += "target coordinate: (" + String(Double(targetLocation.coordinate.latitude)) + ", " + String(Double(targetLocation.coordinate.longitude)) + ")\n"
        debugText += "target altitude: " + String(Double(targetLocation.altitude))
        debugLabel.text = debugText
        
        if pinLocationNode == nil {
            let pinCoordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: targetLocation.altitude)
            let pinImage = UIImage(named: "pin")!
            pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode!)
        }
        
        if distance >= 200 {
            guard let image = UIImage(named: "pin") else { return }
            let plane = SCNPlane(width: image.size.width / 1000, height: image.size.height / 1000)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            pinLocationNode?.annotationNode.geometry = plane
            pinLocationNode?.location = targetLocation
        } else {
            let scaleFactor: CGFloat = CGFloat(1 - (distance / 200) + 0.2)
            guard let image = UIImage(named: "pin") else { return }
            let plane = SCNPlane(width: image.size.width / 200 * scaleFactor, height: image.size.height / 200 * scaleFactor)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            pinLocationNode?.annotationNode.geometry = plane
            pinLocationNode?.location = targetLocation
        }
    }
    
    func update(location: CLLocation) {
        targetLocation = location
    }
    
    let debugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        return label
    }()
    
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}
