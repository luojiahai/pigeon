//
//  LoginView.swift
//  Pigeon
//
//  Created by Tina Luan on 30/8/17.
//  Copyright © 2017 El Root. All rights reserved.
//

import UIKit
// The view for the login page of the app
class LoginView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set up the layout of the whole view
    fileprivate func setupViews() {
        addSubview(logo)
        logo.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: topAnchor, constant: 80).isActive = true
        
        setupInputsContainerView()
        setupLoginAndRegisterButton()
    }
    
    // Set up the layout of the container(a rectangle) of two textfields
    fileprivate func setupInputsContainerView() {
        addSubview(inputsContainerView)
        inputsContainerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 200).isActive
            = true
        inputsContainerView.widthAnchor.constraint(equalTo: widthAnchor, constant: -24).isActive = true
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
    
    // Set up the layout of two buttons: Login and Resister
    fileprivate func setupLoginAndRegisterButton() {
        addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // A container (rectangle) contains two textfields: email and password
    let inputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = linePixel
        return view
    }()
    
    // A button to loginw
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = linePixel
        button.setTitleColor(.lightGray, for: .disabled)
        return button
    }()
    
    // A text field which allows users to type in email address
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
    
    // A black line to seperate the email textfield and password textfield
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    // A text field which allows users to type in password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    // A button which allows users to switch to the register page
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("No account？Sign up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    // Pigeon Logo
    let logo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pigeon"
        label.font = UIFont.systemFont(ofSize: 64)
        label.sizeToFit()
        return label
    }()
    
}
