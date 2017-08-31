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
    
    var delegate: RegisterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    @objc fileprivate func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    fileprivate func setupViews() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        setupInputsContainerView()
        setupRegisterButton()
    }
    
    fileprivate func setupInputsContainerView() {
        view.addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive
            = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(usernameTextField)
        inputsContainerView.addSubview(usernameSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(confirmPasswordTextField)
        
        usernameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4).isActive = true
        
        usernameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        usernameSeparatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        usernameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameSeparatorView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4).isActive = true
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4).isActive = true
        
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true
        
        confirmPasswordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        confirmPasswordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        confirmPasswordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4).isActive = true
    }
    
    fileprivate func setupRegisterButton() {
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(loginText)
        loginText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginText.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12).isActive = true
        loginText.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginText.heightAnchor.constraint(equalToConstant: 25).isActive = true
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
        registerButton.isEnabled = false
        loginText.isEnabled = false
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let username = usernameTextField.text, email != "", password != "", confirmPassword != "", username != "" else {
            let alert = UIAlertController(title: "Error", message: "Please fill in all text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerButton.isEnabled = true
            loginText.isEnabled = true
            return
        }
        
        if !isValidUsername(username) {
            let alert = UIAlertController(title: "Error", message: "Invalid username format\nformat: less than 16 lowercase English characters or numbers", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerButton.isEnabled = true
            loginText.isEnabled = true
            return
        }
        
        if !isValidEmail(email) {
            let alert = UIAlertController(title: "Error", message: "Invalid email address format", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerButton.isEnabled = true
            loginText.isEnabled = true
            return
        }
        
        if !isValidPassword(password) {
            let alert = UIAlertController(title: "Error", message: "Invalid password format\nformat: greater than or equal to 6 numbers or characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerButton.isEnabled = true
            loginText.isEnabled = true
            return
        } else if password != confirmPassword {
            let alert = UIAlertController(title: "Error", message: "Password is not confirmed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            registerButton.isEnabled = true
            loginText.isEnabled = true
            return
        }
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            Database.database().reference().child("usernames").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(username) {
                    let alert = UIAlertController(title: "Error", message: "Username already exist", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerButton.isEnabled = true
                    self.loginText.isEnabled = true
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
                self.registerButton.isEnabled = true
                self.loginText.isEnabled = true
                return
            }
            
            guard let uid = user?.uid else {
                self.registerButton.isEnabled = true
                self.loginText.isEnabled = true
                return
            }
            
            let usernameValues = [username: uid]
            Database.database().reference().child("usernames").updateChildValues(usernameValues, withCompletionBlock: { (err, ref) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerButton.isEnabled = true
                    self.loginText.isEnabled = true
                    return
                }
            })
            
            let values = ["name": username, "username": username, "email": email, "profilePhotoURL": "https://firebasestorage.googleapis.com/v0/b/myapp-6fb8c.appspot.com/o/8261cd74d5dd415096c19ec648189507.png?alt=media&token=8482dcb7-5c69-407b-9707-0f11ea428064"]
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    let alert = UIAlertController(title: "Error", message: "Database failure\n" + String(describing: err), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.registerButton.isEnabled = true
                    self.loginText.isEnabled = true
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
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = linePixel
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = linePixel
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Username"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        return textField
    }()
    
    let usernameSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email address"
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        return textField
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    lazy var loginText: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Already have an account？Sign in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
        return button
    }()
    
}
