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

class AppNotification: NSObject {
    
    static let shared = AppNotification()
    
    /*
     * This function will be called when a new message is sent to a user
     * from currentUser by creating a JSON entry
     * and making a request through onesignal
     */
    
    func sendMessageNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //the JSON entry for a new message notification
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
                    "en": "[\(String(describing: username))]: You've got a new message."
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
    
    func sendRequestNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //the JSON entry for a new friend request notification
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
                    "en": "[\(String(describing: username))]: You've got a new friend request."
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
    
    func sendApproveNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //the JSON entry for a request result notification
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
                    "en": "[\(String(describing: username))]: Your friend request has been approved."
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
    
    func sendLikeNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //the JSON entry for a like notification
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
                    "en": "\(String(describing: username)) likes your footprint."
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
    
    func sendCommentNotification(sender: String, receiver: String) {
        Database.database().reference().child("users").child(sender).child("username").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard let username = dataSnapshot.value as? String else { return }
            
            guard let url = URL(string: "https://onesignal.com/api/v1/notifications") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Basic MGRkNDU1YjUtYzNkMy00ODYwLWIxNDctMTQ4MjAyOWI4MjI2", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //the JSON entry for a comment notification
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
                    "en": "\(String(describing: username)) comments on your footprint."
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
    
}


