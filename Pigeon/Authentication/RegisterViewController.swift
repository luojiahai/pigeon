//
//  RegisterViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

protocol RegisterViewControllerDelegate {
    func loginToDatabase(email: String, password: String)
}

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    // View
    let registerView = RegisterView()
    
    var delegate: RegisterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = registerView
        
        supportViews()
    }
    
    fileprivate func supportViews() {
        registerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        registerView.loginText.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
        registerView.confirmPasswordTextField.delegate = self
        registerView.registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    }
    
    @objc fileprivate func dismissKeyboard() {
        registerView.usernameTextField.resignFirstResponder()
        registerView.emailTextField.resignFirstResponder()
        registerView.passwordTextField.resignFirstResponder()
        registerView.confirmPasswordTextField.resignFirstResponder()
    }
    
    fileprivate func isValidUsername(_ testStr: String) -> Bool {
        let usernameRegEx = "[a-z0-9]*"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: testStr) && testStr.characters.count <= 16
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        // Test if the email address satisfies the regular express
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    fileprivate func isValidPassword(_ testStr: String) -> Bool {
        return testStr.characters.count >= 6
    }
    
    @objc fileprivate func handleRegister() {
        registerView.registerButton.isEnabled = false
        registerView.loginText.isEnabled = false
        
        guard let email = registerView.emailTextField.text, let password = registerView.passwordTextField.text, let confirmPassword = registerView.confirmPasswordTextField.text, let username = registerView.usernameTextField.text, email != "", password != "", confirmPassword != "", username != "" else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerView.registerButton.isEnabled = true
            registerView.loginText.isEnabled = true
            return
        }
        
        if !isValidUsername(username) {
            let alert = UIAlertController(title: "Error", message: "Invalid username format\nformat: less than 16 lowercase English characters or numbers", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerView.registerButton.isEnabled = true
            registerView.loginText.isEnabled = true
            return
        }
        
        if !isValidEmail(email) {
            let alert = UIAlertController(title: "Error", message: "Invalid email address format", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerView.registerButton.isEnabled = true
            registerView.loginText.isEnabled = true
            return
        }
        
        if !isValidPassword(password) {
            let alert = UIAlertController(title: "Error", message: "Invalid password format\nformat: greater than or equal to 6 numbers or characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerView.registerButton.isEnabled = true
            registerView.loginText.isEnabled = true
            return
        } else if password != confirmPassword {
            let alert = UIAlertController(title: "Error", message: "Password is not confirmed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerView.registerButton.isEnabled = true
            registerView.loginText.isEnabled = true
            return
        }
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(username) {
                    let alert = UIAlertController(title: "Error", message: "Username already exist", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerView.registerButton.isEnabled = true
                    self.registerView.loginText.isEnabled = true
                } else {
                    self.register(username: username, email: email, password: password)
                }
                
                do {
                    try Auth.auth().signOut()
                } catch let logoutError {
                    let alert = UIAlertController(title: "Error", message: String(describing: logoutError), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }, withCancel: nil)
        })
        
    }
    
    fileprivate func register(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Failed to register\n" + String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.registerView.registerButton.isEnabled = true
                self.registerView.loginText.isEnabled = true
                return
            }
            
            guard let uid = user?.uid else {
                self.registerView.registerButton.isEnabled = true
                self.registerView.loginText.isEnabled = true
                return
            }
            
            let usernameValues = [username: uid]
            Database.database().reference().child("usernames").updateChildValues(usernameValues, withCompletionBlock: { (err, ref) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerView.registerButton.isEnabled = true
                    self.registerView.loginText.isEnabled = true
                    return
                }
            })
            
            let values = ["name": username, "username": username, "email": email, "profilePhotoURL": "https://firebasestorage.googleapis.com/v0/b/myapp-6fb8c.appspot.com/o/8261cd74d5dd415096c19ec648189507.png?alt=media&token=8482dcb7-5c69-407b-9707-0f11ea428064"]
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerView.registerButton.isEnabled = true
                    self.registerView.loginText.isEnabled = true
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    self.delegate?.loginToDatabase(email: email, password: password)
                    self.dismiss(animated: true, completion: nil)
                })
            })
        })
    }
    
    @objc func switchToLogin() {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
