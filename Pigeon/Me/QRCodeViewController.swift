//
//  QRCodeViewController.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 17/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController, QRScanViewControllerDelegate {
    
    var user: User? {
        didSet {
            let qrCodeImage = generateQRCode(from: "pigeon://" + (user?.uid)!)
            let scaleX = CGFloat(256) / (qrCodeImage?.extent.size.width)!
            let scaleY = CGFloat(256) / (qrCodeImage?.extent.size.height)!
            let transformedImage = qrCodeImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            qrCodeImageView.image = UIImage(ciImage: transformedImage!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupViews()
    }
    // Setup the layout of navigation bar
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "QR Code"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(handleScan))
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .groupTableViewBackground
        
        view.addSubview(qrCodeImageView)
        qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrCodeImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        qrCodeImageView.widthAnchor.constraint(equalToConstant: 256).isActive = true
        qrCodeImageView.heightAnchor.constraint(equalToConstant: 256).isActive = true
    }
    
    // Scan other people's QRcode
    @objc fileprivate func handleScan() {
        let scanVC = QRScanViewController()
        scanVC.delegate = self
        let vc = UINavigationController(rootViewController: scanVC)
        present(vc, animated: false, completion: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // Generate QRcode for current user
    fileprivate func generateQRCode(from string: String) -> CIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            
            if let output = filter.outputImage {
                return output
            }
        }
        
        return nil
    }
    
    let qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderColor = lineColor.cgColor
        imageView.layer.borderWidth = linePixel
        return imageView
    }()

}
