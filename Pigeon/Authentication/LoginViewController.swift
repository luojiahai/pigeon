//
//  LoginViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase
import OneSignal

protocol LoginViewControllerDelegate {
    func reloadData()
}

class LoginViewController: UIViewController, RegisterViewControllerDelegate, UITextFieldDelegate {
	
    // Singleton
    static let sharedInstance = LoginViewController()
    
    // All delegates for LoginViewController
    var delegates: [LoginViewControllerDelegate]?
    
    // View 
    let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view = loginView
        
        supportViews()
    }
	
    // Dismiss the keyboard
    @objc fileprivate func dismissKeyboard() {
        loginView.emailTextField.resignFirstResponder()
        loginView.passwordTextField.resignFirstResponder()
    }
    
    // Add cooresponding functions to different subviews
    fileprivate func supportViews() {
	    loginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginView.passwordTextField.delegate = self
        loginView.registerButton.addTarget(self, action: #selector(switchToRegister), for: .touchUpInside)
    }
    
    // When cancel button has been touched up, dismiss the whole view
    @objc fileprivate func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        // Test if the email address satisfies the regular express
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // When the login button has been touched up
    @objc fileprivate func handleLogin() {
        loginView.loginButton.isEnabled = false
        loginView.registerButton.isEnabled = false
        
        guard let email = loginView.emailTextField.text, let password = loginView.passwordTextField.text, email != "", password != "" 
        else {
            // Send an alert
            let alert = UIAlertController(title: "Error", message: "Invalid input", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            loginView.loginButton.isEnabled = true
            loginView.registerButton.isEnabled = true
            return
        }
		
        // Send an alert for invalid email address
        if !isValidEmail(email) {
            let alert = UIAlertController(title: "Error", message: "Invalid email address format", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            loginView.loginButton.isEnabled = true
            loginView.registerButton.isEnabled = true
            return
        }
        
        loginToDatabase(email: email, password: password)
    }
    
    // Using the given email and password to login to the firebase
	// Pop out an alert if it fails 
    func loginToDatabase(email: String, password: String) {
        
        // The completion closure will be handled by the background thread
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Failed to login\n" + String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.loginView.loginButton.isEnabled = true
                self.loginView.registerButton.isEnabled = true
                return
            }
            
            // Allocate main thread to deal with the closure below
            DispatchQueue.main.async(execute: {
                OneSignal.sendTag("uid", value: user?.uid)
                
                self.delegates?.forEach({ (delegate) in
                    delegate.reloadData()
                })
                
                self.dismiss(animated: true, completion: nil)
				
                // Clear up
                self.loginView.emailTextField.text = ""
                self.loginView.passwordTextField.text = ""
                self.loginView.loginButton.isEnabled = true
                self.loginView.registerButton.isEnabled = true
            })
        })
    }
    
    // When the register button has been touched up
    @objc fileprivate func switchToRegister() {
        let registerVC = RegisterViewController()
        registerVC.delegate = self
        present(registerVC, animated: true, completion: nil)
    
        self.loginView.emailTextField.text = ""
        self.loginView.passwordTextField.text = ""
    }
    
}
