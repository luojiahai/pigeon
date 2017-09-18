//
//  PostFootprintViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 8/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GooglePlaces

class PostFootprintViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var manager: CLLocationManager!
    
    var currentLocation: CLLocation?
    
    var addImageButtonConstraint: NSLayoutConstraint?
    
    var selectedPlace: GMSPlace?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
        setupLocationManager()
    }

    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Post Footprint"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handleDone))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(mapView)
        
        view.addSubview(placeButton)
        placeButton.topAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        placeButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        placeButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        placeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(captionContainerView)
        captionContainerView.topAnchor.constraint(equalTo: placeButton.bottomAnchor, constant: 8).isActive = true
        captionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        captionContainerView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        
        captionContainerView.addSubview(captionTextView)
        
        captionTextView.topAnchor.constraint(equalTo: captionContainerView.topAnchor, constant: 8).isActive = true
        captionTextView.bottomAnchor.constraint(equalTo: captionContainerView.bottomAnchor, constant: -8).isActive = true
        captionTextView.leftAnchor.constraint(equalTo: captionContainerView.leftAnchor, constant: 8).isActive = true
        captionTextView.rightAnchor.constraint(equalTo: captionContainerView.rightAnchor, constant: -8).isActive = true
        
        view.addSubview(imageContainerView)
        imageContainerView.topAnchor.constraint(equalTo: captionContainerView.bottomAnchor).isActive = true
        imageContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        imageContainerView.addSubview(addImageButton)
        addImageButtonConstraint = addImageButton.leftAnchor.constraint(equalTo: imageContainerView.leftAnchor, constant: 8)
        addImageButtonConstraint?.isActive = true
        addImageButton.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 8).isActive = true
        addImageButton.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -8).isActive = true
        addImageButton.widthAnchor.constraint(equalTo: addImageButton.heightAnchor).isActive = true
        
        imageContainerView.addSubview(seperatorLine)
        seperatorLine.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor).isActive = true
        seperatorLine.leftAnchor.constraint(equalTo: imageContainerView.leftAnchor).isActive = true
        seperatorLine.rightAnchor.constraint(equalTo: imageContainerView.rightAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
    }
    
    fileprivate func setupLocationManager() {
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @objc fileprivate func handleSelectPlace() {
        let placesVC = PlacesViewController()
        placesVC.delegate = self
        let vc = UINavigationController(rootViewController: placesVC)
        present(vc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleCancel() {
        if let caption = captionTextView.text, caption != "" || captionImageViews.count > 0 {
            let alert = UIAlertController(title: "Warning", message: "Will lost all filled data\nAre you sure want to quit?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {action in self.dismiss(animated: true, completion: nil)}))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func handleDone() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        var images: [UIImage]?
        captionImageViews.forEach { (imageView) in
            if images == nil {
                images = [UIImage]()
            }
            images?.append(imageView.image!)
        }
        
        guard let text = captionTextView.text, text != "" else {
            let alert = UIAlertController(title: "Post Footprint", message: "text field cannot be empty\nplease write something", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let location = currentLocation else {
            let alert = UIAlertController(title: "Post Footprint", message: "cannot fetch location data\nplease try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let place = selectedPlace else {
            let alert = UIAlertController(title: "Post Footprint", message: "place cannot be empty\nplease select a place", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        
        let values = ["user": currentUser.uid, "timestamp": timestamp, "text": text, "place": place.name] as [String : Any]
        Database.database().reference().child("footprints").childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let locationValues = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude, "altitude": location.altitude]
            Database.database().reference().child("footprints").child(ref.key).child("location").updateChildValues(locationValues, withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            })
            
            var index: Int = 0
            images?.forEach({ (image) in
                let imageName = NSUUID().uuidString
                let uploadData = UIImageJPEGRepresentation(image, 0.25)
                Storage.storage().reference().child("footprint_images").child(ref.key).child("\(imageName).png").putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    if let url = metadata?.downloadURL()?.absoluteString {
                        Database.database().reference().child("footprints").child(ref.key).child("images").updateChildValues(["image\(index)": url], withCompletionBlock: { (error, ref) in
                            if let error = error {
                                let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        })
                    }
                    
                    index += 1
                })
            })
            
            let footprintValues = [ref.key: timestamp]
            Database.database().reference().child("user-footprints").child(currentUser.uid).updateChildValues(footprintValues, withCompletionBlock: { (error, ref) in
                if let error = error {
                    let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            })
            
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first ?? nil
        
        UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.mapView.setCenter((self.currentLocation?.coordinate)!, animated: false)
        }, completion: {
            _ in
            self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        })
    }
    
    fileprivate func addCaptionImageView(_ image: UIImage) {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = linePixel
        imageView.layer.borderColor = lineColor.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDeleteImage)))
        captionImageViews.append(imageView)
        
        var lastImageViewRightAnchor: NSLayoutXAxisAnchor?
        captionImageViews.forEach { (imageView) in
            imageContainerView.addSubview(imageView)
            if let lastAnchor = lastImageViewRightAnchor {
                imageView.leftAnchor.constraint(equalTo: lastAnchor, constant: 8).isActive = true
            } else {
                imageView.leftAnchor.constraint(equalTo: imageContainerView.leftAnchor, constant: 8).isActive = true
            }
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 8).isActive = true
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -8).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            lastImageViewRightAnchor = imageView.rightAnchor
        }
        
        if captionImageViews.count >= 3 {
            addImageButton.isHidden = true
        } else {
            addImageButtonConstraint?.constant += 92
        }
    }
    
    fileprivate func deleteCaptionImageView(_ imageView: UIImageView) {
        let alert = UIAlertController(title: "Delete Photo", message: "Feature coming soon...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    lazy var placeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("📍 Please select a place", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(handleSelectPlace), for: .touchUpInside)
        return button
    }()
    
    let captionContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let captionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = lineColor
        return view
    }()
    
    let imageContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var addImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("addPhoto", for: .normal)
        button.setTitleColor(lineColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.borderWidth = linePixel
        button.layer.borderColor = lineColor.cgColor
        button.addTarget(self, action: #selector(handleAddImage), for: .touchUpInside)
        return button
    }()
    
    var captionImageViews = [UIImageView]()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/4)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        return mapView
    }()
    
}

extension PostFootprintViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc fileprivate func handleAddImage() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Photos", style: .default) { (UIAlertAction) in self.openPhotoLibrary() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleDeleteImage(_ sender: UIImageView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive) { (UIAlertAction) in self.deleteCaptionImageView(sender) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func openCamera() {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.camera
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }

    fileprivate func openPhotoLibrary() {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            addCaptionImageView(selectedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension PostFootprintViewController: PlacesDataDelegate {
    
    func selectPlace(_ place: GMSPlace) {
        selectedPlace = place
        placeButton.setTitle("📍 " + place.name, for: .normal)
        placeButton.setTitleColor(.black, for: .normal)
    }
    
}
