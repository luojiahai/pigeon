//
//  QRScannerControllerViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/16.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerControllerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // video showing to user (camera)
    var video = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        
        // Creating session (video)
        let session = AVCaptureSession()
        
        // Default capture device
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        // setup input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!) // get from camera
            session.addInput(input) // put input into session
            
        } catch {
            print("ERROR")
        }
        
        // setup output
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "QRScanner"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }

    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    // QR code
                    let alert = UIAlertController(title: "QR Code", message: object.stringValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: {(nil) in UIPasteboard.general.string = object.stringValue}))
                    
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }

}
