//
//  SignUpViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 06/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    //TODO: is user still neccessary?
    //private var user: User?
    private var userRef: DatabaseReference?
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sign Up"
        userRef = Database.database().reference()
        
        //done button for pickerview
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        toolbar.setItems([flexibleSpace ,doneButton], animated: true)
        userNameTextField.inputAccessoryView = toolbar
        userSurnameTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        contactNumberTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        checkPasswordTextField.inputAccessoryView = toolbar
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if isUserDetailsNotEmpty() {
            if isPasswordValid() {
                let email =  emailTextField.text!
                let password = passwordTextField.text!
                //creating user for firebase auth
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        //user
                        let user = Auth.auth().currentUser!
                        let userName = self.userNameTextField.text!
                        let userSurname = self.userSurnameTextField.text!
                        let contactNumber = self.contactNumberTextField.text!
                        //adding user to realtime database
                        self.userRef!.child("users").child(user.uid).setValue(
                            ["firstName": "\(userName)",
                                "lastName": "\(userSurname)",
                                "email": "\(email)",
                                "contactNumber": "\(contactNumber)"])
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Password do not match", message: "Please check passwords fields", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Empty fields", message: "Please fill all User Details Field", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //validation methods
    private func isPasswordValid() -> Bool {
        return passwordTextField.hasText && (passwordTextField.text == checkPasswordTextField.text)
    }
    
    private func isUserDetailsNotEmpty() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText && emailTextField.hasText && contactNumberTextField.hasText && passwordTextField.hasText && checkPasswordTextField.hasText
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
}

