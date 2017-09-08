//
//  PostFootprintViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 8/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class PostFootprintViewController: UIViewController {
    
    var addImageButtonConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupNavigation()
    }

    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.title = "Post Footprint"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handleDone))
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
        
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(captionContainerView)
        captionContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        captionContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        captionContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        captionContainerView.heightAnchor.constraint(equalToConstant: 144).isActive = true
        
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
    
    fileprivate func addCaptionImageView(_ image: UIImage) {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
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
