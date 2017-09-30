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

protocol ARViewControllerDelegate {
    func updateLocation() -> CLLocation?
    func handleCancel()
}

class ARViewController: UIViewController {
    
    var delegate: ARViewControllerDelegate?
    
    let sceneLocationView = SceneLocationView()
    
    // Target user
    var targetLocation: CLLocation?
    var targetLocationNode: LocationAnnotationNode?
    var targetUserAnnotation: MKPointAnnotation?
    
    // Updating timer
    var updateLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?
    
    // Footprints
    var footprints: [Footprint]?
    var footprintNodes: [LocationAnnotationNode] = []
    var footprintViewImages: [UIImage] = []
    
    //    var adjustNorthByTappingSidesOfScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupTargetAnnotation()
        setupFootprints()
        setupTimers()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "AR"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(handleMap))
    }
    
    fileprivate func setupTargetAnnotation() {
        if let targetLocation = targetLocation {
            // Add pin
            let coordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let location = CLLocation(coordinate: coordinate, altitude: targetLocation.altitude)
            let image = UIImage(named: "pin")!
            targetLocationNode = LocationAnnotationNode(location: location, image: image)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: targetLocationNode!)
        }
    }
    
    fileprivate func setupFootprints() {
        
        if footprints == nil || footprints?.count == 0 {
            return
        }
        
        // rendering each footprint
        for footprint in footprints! {
            
            let coordinate = CLLocationCoordinate2D(latitude: footprint.latitude!, longitude: footprint.longitude!)
            let footprintLocation = CLLocation(coordinate: coordinate, altitude: footprint.altitude!)
            
            // Popover view controller
            let vc = FootprintopoverViewController()
            vc.footprint = footprint
            
            vc.view.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
            
            // Get the view and conver into image
            let image = UIImage(view: vc.view)
            
            // Store the image in the array
            footprintViewImages.append(image)
            
            let locationNode = LocationAnnotationNode(location: footprintLocation, image: image)
            
            let scaleFactor: CGFloat = 0
            
            // Adjust annotation scale
            let plane = SCNPlane(width: image.size.width / 100 * scaleFactor, height: image.size.height / 100 * scaleFactor)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            locationNode.annotationNode.geometry = plane
            
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
            
            // Store the node in the array
            footprintNodes.append(locationNode)
        }
        
    }
    
    func setupTimers() {
        // Updating infoLabel
        updateInfoLabelTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(ARViewController.updateInfoLabel),
            userInfo: nil,
            repeats: true)
        
        updateLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(ARViewController.updateLocation),
            userInfo: nil,
            repeats: true)
    }
    
    func setupViews() {
        // Set to true to display an arrow which points north.
        //        sceneLocationView.orientToTrueNorth = false
        //        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        
        //        sceneLocationView.showAxesNode = false
        //        sceneLocationView.showFeaturePoints = true
        
        view.addSubview(sceneLocationView)
        
        sceneLocationView.locationDelegate = self
        
        sceneLocationView.addSubview(infoLabel)
        
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
        
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        
        infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
    }
    
    @objc fileprivate func updateLocation() {
        updateTarget()
        updateFootprints()
    }
    
    fileprivate func updateFootprints() {
        
        if footprints == nil || footprints?.count == 0 {
            return
        }
        
        let count = footprintNodes.count - 1
        
        for i in 0...count {
            let footprintNode = footprintNodes[i]
            let image = footprintViewImages[i]
            
            // Calculate distance
            guard let currentLocation = sceneLocationView.currentLocation() else { return }
            let distance = currentLocation.distance(from: footprintNode.location)
            
            var scaleFactor: CGFloat
            
            // Show footprints within 200 metres only
            if distance <= 200 {
                scaleFactor = CGFloat(1 - (distance / 200) + 0.2)
            } else {
                scaleFactor = 0
            }
            
            // Adjust annotation scale
            let plane = SCNPlane(width: image.size.width / 100 * scaleFactor, height: image.size.height / 100 * scaleFactor)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            footprintNode.annotationNode.geometry = plane
        }
    }
    
    fileprivate func updateTarget() {  // ???
        
        targetLocation = delegate?.updateLocation()
        
        if let targetLocation = targetLocation {
            DispatchQueue.main.async {
                if self.targetUserAnnotation == nil {
                    self.targetUserAnnotation = MKPointAnnotation()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.targetUserAnnotation?.coordinate = targetLocation.coordinate
                }, completion: nil)
            }
        }
        
        guard let currentLocation = sceneLocationView.currentLocation() else { return }
        guard let targetLocation = targetLocation else { return }
        let distance = currentLocation.distance(from: targetLocation)
        
        var debugText = String()
        debugText += "target distance: " + String(Int(distance)) + " metres\n"
        debugText += "target coordinate: (" + String(Double(targetLocation.coordinate.latitude)) + ", " + String(Double(targetLocation.coordinate.longitude)) + ")\n"
        debugText += "target altitude: " + String(Double(targetLocation.altitude))
        debugLabel.text = debugText
        
        if targetLocationNode == nil {
            let pinCoordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: targetLocation.altitude)
            let pinImage = UIImage(named: "pin")!
            targetLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: targetLocationNode!)
        }
        
        // Adjust annotation scale
        if distance >= 200 {
            guard let image = UIImage(named: "pin") else { return }
            let plane = SCNPlane(width: image.size.width / 1000, height: image.size.height / 1000)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            targetLocationNode?.annotationNode.geometry = plane
            targetLocationNode?.location = targetLocation
        } else {
            let scaleFactor: CGFloat = CGFloat(1 - (distance / 200) + 0.2)
            guard let image = UIImage(named: "pin") else { return }
            let plane = SCNPlane(width: image.size.width / 200 * scaleFactor, height: image.size.height / 200 * scaleFactor)
            plane.firstMaterial!.diffuse.contents = image
            plane.firstMaterial!.lightingModel = .constant
            targetLocationNode?.annotationNode.geometry = plane
            targetLocationNode?.location = targetLocation
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
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        super.touchesBegan(touches, with: event)
    //
    //        if let touch = touches.first {
    //            if touch.view != nil {
    ////                if (mapView == touch.view! ||
    ////                    mapView.recursiveSubviews().contains(touch.view!)) {
    ////                    centerMapOnUserLocation = false
    ////                } else {
    //
    //                    let location = touch.location(in: self.view)
    //
    //                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen {
    //                        print("left side of the screen")
    //                        sceneLocationView.moveSceneHeadingAntiClockwise()
    //                    } else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen {
    //                        print("right side of the screen")
    //                        sceneLocationView.moveSceneHeadingClockwise()
    //                    } else {
    //                        //                        let image = UIImage(named: "pin")!
    //                        //                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
    //                        //                        annotationNode.scaleRelativeToDistance = true
    //                        //                        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
    //                    }
    ////                }
    //            }
    //        }
    //    }
    
    let debugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .white
        return label
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.numberOfLines = 0
        return label
    }()
    
}
