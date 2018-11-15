//
//  ViewController.swift
//  Parking Space Booking System
//
//  Created by Tasneem Bohra on 2018-11-01.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //TODO: figure out how to proceed with firebase and rememberMe switchs
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login"
        if Auth.auth().currentUser != nil {
            goToMainScreen()
        }
        rememberMeSwitch.onTintColor = #colorLiteral(red: 1, green: 0.4995798148, blue: 0.5078817425, alpha: 1)
        signUpOutlet.layer.cornerRadius = 5
        signUpOutlet.layer.borderWidth = 1
        loginOutlet.layer.cornerRadius = 5
        loginOutlet.layer.borderWidth = 1
        
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
//        let userDefault = UserDefaults.standard
//        if userDefault.string(forKey: "userName") != nil {
//            userNameTextField.text = userDefault.string(forKey: "userName")
//            passwordTextField.text = userDefault.string(forKey: "password")
//            goToMainScreen()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func loginButton(_ sender: UIButton) {
        login()
    }
    
    @IBAction func signUp(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let signupVC = sb.instantiateViewController(withIdentifier: "signupVC")
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if error == nil {
                let userDefault = UserDefaults.standard
                userDefault.setValue(self.logDate(), forKey: "logDate")
                self.goToMainScreen()
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func isUserValid() -> Bool {
        var isValid = false;
        for user in User.allUsers {
            if userNameTextField.text == user.email && passwordTextField.text == user.password {
                isValid = true
                break
            }
        }
        return isValid
    }
    
    private func logDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    
    private func goToMainScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = sb.instantiateViewController(withIdentifier: "mainVC")
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    private func jumpToPasswordField() {
        self.passwordTextField.becomeFirstResponder()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.tag == 1 ? login() : jumpToPasswordField()
        return true
    }
}

