//
//  AppNotification.swift
//  Pigeon
//
//  Created by Geoffrey Ka-Hoi Law on 21/9/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import Foundation
import OneSignal
import Firebase

/*
 * five types of notification supported
 * - new message
 * - friend request
 * - friend request approve
 * - footprint like
 * - footprint like
 */

class AppNotification: NSObject {
    
    static let shared = AppNotification()
    
    fileprivate func sendNotification(with text: String, sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonObject: [String: Any] = [
                "app_id": "eb1565de-1624-4ab0-8392-ff39800489d2",
                "filters": [
                    [
                        "field": "tag",
                        "key": "uid",
                        "relation": "=",
                        "value": receiver
                    ]
                ],
                "contents": [
                    "en": "[\(String(describing: username))]: " + text
                ]
            ]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error JSON")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
        }
    }
    
    func sendMessageNotification(sender: String, receiver: String) {
       sendNotification(with: "You've got a new message.", sender: sender, receiver: receiver)
    }
    
    func sendRequestNotification(sender: String, receiver: String) {
       sendNotification(with: "You've got a new friend request.", sender: sender, receiver: receiver)
    }
    
    func sendApproveNotification(sender: String, receiver: String) {
       sendNotification(with: "Your friend request has been approved.", sender: sender, receiver: receiver)
    }
    
    func sendLikeNotification(sender: String, receiver: String) {
       sendNotification(with: "likes your footprint.", sender: sender, receiver: receiver)
    }
    
    func sendCommentNotification(sender: String, receiver: String) {
       sendNotification(with: "comments on your footprint.", sender: sender, receiver: receiver)
    }
    
}


