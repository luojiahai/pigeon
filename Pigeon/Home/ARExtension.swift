//
//  ARExtension.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/29.
//  Copyright © 2017 El Root. All rights reserved.
//

import MapKit
import ARKit
import SceneKit
import UIKit


extension ARViewController: MKMapViewDelegate {
    
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
    
}

extension ARViewController: SceneLocationViewDelegate {
    
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
        
        if targetLocationNode == nil {
            let pinCoordinate = CLLocationCoordinate2D(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
            let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: targetLocation.altitude)
            let pinImage = UIImage(named: "pin")!
            targetLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: targetLocationNode!)
        }
        
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
    
}
