//
//  ViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 11/13/18.
//  Copyright © 2018 codeRIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginLoadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //Listening for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func loginButtonPressed() {
        loginButton.isUserInteractionEnabled = false
        loginButton.setTitle("", for: .normal)
        loginLoadingSpinner.isHidden = false
        emailTextField.isUserInteractionEnabled = false
        passwordTextField.isUserInteractionEnabled = false
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        view.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: Notification){
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        if notification.name == UIApplication.keyboardWillShowNotification  && !passwordTextField.isFirstResponder || notification.name == UIApplication.keyboardWillChangeFrameNotification && !passwordTextField.isFirstResponder{
            view.frame.origin.y = -keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailTextField.isFirstResponder{
            passwordTextField.becomeFirstResponder()
        }else{
            view.frame.origin.y = 0
            passwordTextField.resignFirstResponder()
            emailTextField.isUserInteractionEnabled = false
            passwordTextField.isUserInteractionEnabled = false
            loginButtonPressed()
        }
        return true
    }
}

