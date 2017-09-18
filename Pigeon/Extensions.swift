//
//  Extensions.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation
import UIKit

let linePixel = 1 / UIScreen.main.scale
let lineColor = UITableView().separatorColor!

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageURLString: String?
    
    func loadImageUsingCache(with urlString: String, completion: (() -> Void)? = nil) {
        
        imageURLString = urlString as String?
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                if let downloadedImage = UIImage(data: data!) {
                    if self.imageURLString == urlString {
                        self.image = downloadedImage
                    }
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                }
                if let completionHandler = completion {
                    completionHandler()
                }
            })
            
        }).resume()
    }
    
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
