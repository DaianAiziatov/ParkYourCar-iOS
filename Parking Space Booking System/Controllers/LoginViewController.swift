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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Login"
        if Auth.auth().currentUser != nil {
            goToMainScreen()
        }
//        let userDefault = UserDefaults.standard
//        if userDefault.string(forKey: "userName") != nil {
//            userNameTextField.text = userDefault.string(forKey: "userName")
//            passwordTextField.text = userDefault.string(forKey: "password")
//            goToMainScreen()
//        }
    }
    
    //hiding navigation comtroller from login screen
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }

    @IBAction func login(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if error == nil {
                self.goToMainScreen()
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
//        if isUserValid() {
//            let userDefault = UserDefaults.standard
//            if rememberMeSwitch.isOn {
//                userDefault.set(userNameTextField.text, forKey: "userName")
//                userDefault.set(passwordTextField.text, forKey: "password")
//            } else {
//                userDefault.removeObject(forKey: "userName")
//                userDefault.removeObject(forKey: "password")
//            }
//            goToMainScreen()
//        } else {
//            let alert = UIAlertController(title: "Unsuccesfull login", message: "Invalid login/password\nTry once again", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
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
    
    
    @IBAction func signUp(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let signupVC = sb.instantiateViewController(withIdentifier: "signupVC")
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    private func goToMainScreen() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = sb.instantiateViewController(withIdentifier: "mainVC")
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
}

