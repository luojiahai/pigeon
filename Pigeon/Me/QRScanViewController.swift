//
//  QRScannerControllerViewController.swift
//  Pigeon
//
//  Created by Pei Yun Sun on 2017/9/16.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
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
    }
    
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.title = "QR Scan"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    // QR code
                    guard let str = object.stringValue else { return }
                    let index = str.index(str.startIndex, offsetBy: 9)
                    let prefix = str[..<index]
                    let suffix = str[index...]
                    if prefix == "pigeon://" {
                        video.session?.stopRunning()
                        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
                            if dataSnapshot.hasChild(String(suffix)) {
                                guard let dictionary = dataSnapshot.childSnapshot(forPath: String(suffix)).value as? [String : AnyObject] else { return }
                                let user = User(uid: String(suffix), dictionary)
                                let vc = UserProfileViewController()
                                vc.user = user
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                self.video.session?.startRunning()
                            }
                        })
                    } else {
                        let alert = UIAlertController(title: "QR Scan", message: "The QR Code is not associated with Pigeon\nPlease try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        video.session?.startRunning()
    }

}
