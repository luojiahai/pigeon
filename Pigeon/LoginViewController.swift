//
//  LoginViewController.swift
//  Pigeon
//
//  Created by Meng Yuan on 27/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, RegisterViewControllerDelegate, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
    }
    
    @objc fileprivate func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    fileprivate func setupViews() {
        view.addSubview(cancelButton)
        
        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        view.addSubview(logo)
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        
        setupInputsContainerView()
        setupLoginButton()
    }
    
    fileprivate func setupInputsContainerView() {
        view.addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive
            = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)

        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true

        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: linePixel).isActive = true

        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
    }
    
    fileprivate func setupLoginButton() {
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    @objc fileprivate func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @objc fileprivate func handleLogin() {
        loginButton.isEnabled = false
        registerButton.isEnabled = false
        
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != "" else {
            let alert = UIAlertController(title: "Error", message: "Invalid input", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            loginButton.isEnabled = true
            registerButton.isEnabled = true
            return
        }
        
        if !isValidEmail(email) {
            let alert = UIAlertController(title: "Error", message: "Invalid email address format", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            loginButton.isEnabled = true
            registerButton.isEnabled = true
            return
        }
        
        loginToDatabase(email: email, password: password)
    }
    
    func loginToDatabase(email: String, password: String) {
        
        // The completion closure will be
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Failed to login\n" + String(describing: error), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.loginButton.isEnabled = true
                self.registerButton.isEnabled = true
                return
            }
            
            // allocate main thread to deal with the closure below
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
                
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.loginButton.isEnabled = true
                self.registerButton.isEnabled = true
            })
        })
    }
    
    @objc fileprivate func switchToRegister() {
        let registerVC = RegisterViewController()
        registerVC.delegate = self
        present(registerVC, animated: true, completion: nil)
    
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = linePixel
        return view
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = linePixel
        button.setTitleColor(.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.keyboardType = UIKeyboardType.emailAddress
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
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("No account？Sign up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(switchToRegister), for: .touchUpInside)
        return button
    }()
    
    let logo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pigeon"
        label.font = UIFont.systemFont(ofSize: 64)
        label.sizeToFit()
        return label
    }()
    
}
