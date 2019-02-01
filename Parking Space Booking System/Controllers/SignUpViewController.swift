//
//  SignUpViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 06/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController, AlertDisplayable, LoadingDisplayable {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var signUpOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Sign Up"
        initialization()
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        signUp()
    }
    
    private func signUp() {
        guard isUserDetailsNotEmpty() else {
            displayAlert(with: "Empty fields", message: "Please fill all User Details Field")
            return
        }
        
        guard isPasswordValid() else {
            displayAlert(with: "Password does not match", message: "Please check passwords fields")
            return
        }
        startLoading()
        let password = passwordTextField.text!
        let appuser = AppUser(firstName: userNameTextField.text!,
                              lastName: userSurnameTextField.text!,
                              email: emailTextField.text!,
                              contactNumber: contactNumberTextField.text!)
        FirebaseManager.sharedInstance().signUp(appuser: appuser, with: password) { error in
            if let error = error {
                self.stopLoading {
                    self.displayAlert(with: "Error", message: error.localizedDescription)
                }
            } else {
                self.stopLoading {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: -Validation methods
    private func isPasswordValid() -> Bool {
        return passwordTextField.hasText && (passwordTextField.text == checkPasswordTextField.text)
    }
    
    private func isUserDetailsNotEmpty() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText
            && emailTextField.hasText && contactNumberTextField.hasText
            && passwordTextField.hasText && checkPasswordTextField.hasText
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    //MARK: -Initialization
    private func initialization() {
        //round buttons' corners
        signUpOutlet.layer.cornerRadius = 5
        signUpOutlet.layer.borderWidth = 1
        //done button for pickerview and textview
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        toolbar.setItems([flexibleSpace ,doneButton], animated: true)
        userNameTextField.inputAccessoryView = toolbar
        userNameTextField.tag = 0
        userNameTextField.delegate = self
        userSurnameTextField.inputAccessoryView = toolbar
        userSurnameTextField.tag = 1
        userSurnameTextField.delegate = self
        emailTextField.inputAccessoryView = toolbar
        emailTextField.tag = 2
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contactNumberTextField.inputAccessoryView = toolbar
        contactNumberTextField.tag = 3
        contactNumberTextField.delegate = self
        passwordTextField.inputAccessoryView = toolbar
        passwordTextField.tag = 4
        passwordTextField.delegate = self
        checkPasswordTextField.inputAccessoryView = toolbar
        checkPasswordTextField.tag = 5
        checkPasswordTextField.delegate = self
        checkPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
}

// MARK: -TextField Delegate
extension SignUpViewController: UITextFieldDelegate {
    
    //return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: jumpTo(textField: userSurnameTextField)
        case 1: jumpTo(textField: emailTextField)
        case 2: jumpTo(textField: contactNumberTextField)
        case 3: jumpTo(textField: passwordTextField)
        case 4: jumpTo(textField: checkPasswordTextField)
        case 5: signUp()
        default: print("no such field")
        }
        return true
    }
    
    //fields validation
    @objc func textFieldDidChange(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }
        guard let floatingLabelTextField = textfield as? SkyFloatingLabelTextField else {
            return
        }
        if textfield.tag == 2 {
            if (text.count < 3 || !text.contains("@")) {
                floatingLabelTextField.errorMessage = "Invalid email"
            }
            else {
                // The error message will only disappear when we reset it to nil or empty string
                floatingLabelTextField.errorMessage = ""
            }
        } else if textfield.tag == 5 {
            let passwordtext = passwordTextField.text!
            if (text != passwordtext) {
                floatingLabelTextField.errorMessage = "Passwords are different"
            } else {
                floatingLabelTextField.errorMessage = ""
            }
        }
    }
    
}
