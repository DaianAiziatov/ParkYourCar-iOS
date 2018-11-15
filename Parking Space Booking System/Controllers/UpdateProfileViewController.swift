//
//  UpdateProfileViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 08/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class UpdateProfileViewController: UIViewController {

    private let user = Auth.auth().currentUser!
    private var userRef = Database.database().reference()

    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var updateOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Update user profile"
        screenPreparation()
        //add info where possible
        addInfoInTextFields()
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        if isUserFieldsFilled() {
            update()
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please fill all user information fields", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    private func update() {
        let key = userRef.child("users").child(user.uid).key
        print(key!)
        //user
        let userName = self.userNameTextField.text!
        let userSurname = self.userSurnameTextField.text!
        let contactNumber = self.contactNumberTextField.text!
        //car
        let userData = ["firstName": "\(userName)", "lastName": "\(userSurname)", "email": "\(user.email ?? "")", "contactNumber": "\(contactNumber)"] as [String : Any]
        let childUpdates = ["/users/\(key ?? "")": userData]
        userRef.updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                self.updatePassword()
                print("Data saved successfully!")
            }
        }
        
    }
    
    private func updatePassword() {
        if isPasswordValid() {
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPasswordTextField.text!)
            user.reauthenticateAndRetrieveData(with: credential, completion: { (autDataResult, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    print("Password couldn't be changed: \(error).")
                } else {
                    self.user.updatePassword(to: self.newPasswordTextField.text!)
                    self.navigationController?.popViewController(animated: true)
                }})
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func addInfoInTextFields() {
        emailTextLabel.text = "Email: \(user.email ?? "")"
        userRef.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userNameTextField.text = value?["firstName"] as? String ?? ""
            self.userSurnameTextField.text = value?["lastName"] as? String ?? ""
            self.contactNumberTextField.text = value?["contactNumber"] as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func isUserFieldsFilled() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText && contactNumberTextField.hasText
    }
    
    private func isPasswordValid() -> Bool {
        return oldPasswordTextField.hasText && newPasswordTextField.hasText && (newPasswordTextField.text == checkPasswordTextField.text)
    }
    
    private func screenPreparation() {
        updateOutlet.layer.cornerRadius = 5
        updateOutlet.layer.borderWidth = 1
        //done button for pickerview
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
        contactNumberTextField.inputAccessoryView = toolbar
        contactNumberTextField.tag = 2
        contactNumberTextField.delegate = self
        oldPasswordTextField.inputAccessoryView = toolbar
        oldPasswordTextField.tag = 3
        oldPasswordTextField.delegate = self
        newPasswordTextField.inputAccessoryView = toolbar
        newPasswordTextField.tag = 4
        newPasswordTextField.delegate = self
        checkPasswordTextField.inputAccessoryView = toolbar
        checkPasswordTextField.tag = 5
        checkPasswordTextField.delegate = self
        checkPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
}

extension UpdateProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: jumpTo(textField: userSurnameTextField)
        case 1: jumpTo(textField: contactNumberTextField)
        case 2: jumpTo(textField: oldPasswordTextField)
        case 3: jumpTo(textField: newPasswordTextField)
        case 4: jumpTo(textField: checkPasswordTextField)
        case 5: update()
        default: print("no such field")
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                if textfield.tag == 5 {
                    let passwordtext = newPasswordTextField.text!
                    if (text != passwordtext) {
                        floatingLabelTextField.errorMessage = "Passwords are different"
                    } else {
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    }
    
}
