//
//  ViewController.swift
//  Parking Space Booking System
//
//  Created by Tasneem Bohra on 2018-11-01.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import KeychainAccess

class LoginViewController: UIViewController, AlertDisplayable {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func loginButton(_ sender: UIButton) {
        if areFieldsFilled() {
            login()
        } else {
            displayAlert(with: "Error", message:  "Please fill login information")
        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let signupVC = sb.instantiateViewController(withIdentifier: "signupVC")
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    private func login() {
        FirebaseManager.sharedInstance().login(with: userNameTextField.text!, password: passwordTextField.text!) { error in
            if let error = error {
                self.displayAlert(with: "Error", message:  error.localizedDescription)
            } else {
                let keychain = Keychain(service: "com.lambton.Parking-Space-Booking-System")
                if self.rememberMeSwitch.isOn {
                    keychain["username"] = self.userNameTextField.text!
                    keychain["password"] = self.passwordTextField.text!
                } else {
                    let keychain = Keychain(service: "com.lambton.Parking-Space-Booking-System")
                    keychain["username"] = nil
                    keychain["password"] = nil
                }
                keychain["logdate"] = self.logDate()
                self.goToMainScreen()
            }
        }
    }

    // MARK: -Initialization
    private func initialization() {
        self.navigationItem.title = "Login"
        rememberMeSwitch.onTintColor = #colorLiteral(red: 0.8894551079, green: 0.2323677188, blue: 0.1950711468, alpha: 1)
        //round buttons
        signUpOutlet.layer.cornerRadius = 5
        signUpOutlet.layer.borderWidth = 1
        loginOutlet.layer.cornerRadius = 5
        loginOutlet.layer.borderWidth = 1
        //toolbar with "done" button for keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        toolbar.setItems([flexibleSpace ,doneButton], animated: true)
        userNameTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        userNameTextField.tag = 0
        passwordTextField.tag = 1
        //remember me
        let keychain = Keychain(service: "com.lambton.Parking-Space-Booking-System-Group4")
        if keychain["username"] != nil {
            userNameTextField.text = keychain["username"]
            passwordTextField.text = keychain["password"]
        }
    }
    
    private func areFieldsFilled() -> Bool {
        return userNameTextField.hasText && passwordTextField.hasText
    }
    
    private func logDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    
    private func goToMainScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = sb.instantiateViewController(withIdentifier: "tabVC")
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    private func jumpToPasswordField() {
        self.passwordTextField.becomeFirstResponder()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
}

// MARK: -TextFiel Delegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.tag == 1 ? login() : jumpToPasswordField()
        return true
    }
}

