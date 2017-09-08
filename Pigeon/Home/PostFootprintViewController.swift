//
//  PostFootprintViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 8/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class PostFootprintViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupNavigation()
    }

    func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Post Footprint"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handleDone))
    }
    
    @objc func handleCancel() {
//        if let caption = captionTextView.text, caption != "" || captionImageView.image != nil {
//            let alert = UIAlertController(title: "Warning", message: "Will lost all filled data", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Leave", style: UIAlertActionStyle.default, handler: {action in self.dismiss(animated: true, completion: nil)}))
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
//        } else {
//            dismiss(animated: true, completion: nil)
//        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        
    }
    
    func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(captionContainerView)
        captionContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        captionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        captionContainerView.heightAnchor.constraint(equalToConstant: 144).isActive = true
        
        captionContainerView.addSubview(captionTextView)
        
        captionTextView.topAnchor.constraint(equalTo: captionContainerView.topAnchor, constant: 4).isActive = true
        captionTextView.bottomAnchor.constraint(equalTo: captionContainerView.bottomAnchor, constant: -4).isActive = true
        captionTextView.leftAnchor.constraint(equalTo: captionContainerView.leftAnchor, constant: 4).isActive = true
        captionTextView.rightAnchor.constraint(equalTo: captionContainerView.rightAnchor, constant: -4).isActive = true
        
        captionContainerView.addSubview(seperatorLine)
        seperatorLine.bottomAnchor.constraint(equalTo: captionContainerView.bottomAnchor).isActive = true
        seperatorLine.leftAnchor.constraint(equalTo: captionContainerView.leftAnchor).isActive = true
        seperatorLine.rightAnchor.constraint(equalTo: captionContainerView.rightAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
    }
    
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
    
}

extension PostFootprintViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc fileprivate func handleAddImage() {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in self.openCamera() })
//        alert.addAction(UIAlertAction(title: "Photos", style: .default) { (UIAlertAction) in self.openPhotoLibrary() })
//        if captionImageView.image != nil {
//            alert.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.destructive, handler: { (UIAlertAction) in self.captionImageView.image = nil}))
//        }
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
    
//    fileprivate func openCamera() {
//        let picker = UIImagePickerController()
//
//        picker.delegate = self
//        picker.sourceType = UIImagePickerControllerSourceType.camera
//        picker.allowsEditing = true
//
//        present(picker, animated: true, completion: nil)
//    }
//
//    fileprivate func openPhotoLibrary() {
//        let picker = UIImagePickerController()
//
//        picker.delegate = self
//        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        picker.allowsEditing = true
//
//        present(picker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        var selectedImageFromPicker: UIImage?
//
//        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
//            selectedImageFromPicker = editedImage
//        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
//            selectedImageFromPicker = originalImage
//        }
//
//        if let selectedImage = selectedImageFromPicker {
//            captionImageView.image = selectedImage
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
    
}
