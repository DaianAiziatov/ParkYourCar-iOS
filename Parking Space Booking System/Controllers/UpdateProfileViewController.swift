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

class UpdateProfileViewController: UIViewController, AlertDisplayable {

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
        initialization()
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        guard isUserFieldsFilled() else {
            displayAlert(with: "Error", message: "Please fill all user information fields")
            return
        }
        update()
    }
    
    private func update() {
        let appuser = AppUser(firstName: userNameTextField.text!,
                              lastName: userSurnameTextField.text!,
                              email: nil,
                              contactNumber: contactNumberTextField.text!)
        FirebaseManager.sharedInstance().updateInfo(with: appuser) { error in
            if let error = error {
                self.displayAlert(with: "Error", message: error.localizedDescription)
            } else {
                self.updatePassword()
            }
        }
    }
    
    private func updatePassword() {
        guard isPasswordValid() else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        FirebaseManager.sharedInstance().update(oldPassword: oldPasswordTextField.text!, with: newPasswordTextField.text!) {
            error in
            if let error = error {
                self.displayAlert(with: "Error", message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func addInfoInTextFields() {
        FirebaseManager.sharedInstance().getUserInfo { result in
            switch result {
            case .failure(let error): self.displayAlert(with: "Error", message: error.localizedDescription)
            case .success(let appuser):
                self.emailTextLabel.text = "Email: \(appuser.email ?? "")"
                self.userNameTextField.text = appuser.firstName
                self.userSurnameTextField.text = appuser.lastName
                self.contactNumberTextField.text = appuser.contactNumber
            }
        }
    }
    
    private func isUserFieldsFilled() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText && contactNumberTextField.hasText
    }
    
    private func isPasswordValid() -> Bool {
        return oldPasswordTextField.hasText && newPasswordTextField.hasText
            && (newPasswordTextField.text == checkPasswordTextField.text)
    }
    
    // MARK: -Initialization
    private func initialization() {
        //round buttons; corners
        updateOutlet.layer.cornerRadius = 5
        updateOutlet.layer.borderWidth = 1
        //done button for pickerview and textfields
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
        //add info where possible
        addInfoInTextFields()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
}

// MARK: -TextField Delegate
extension UpdateProfileViewController: UITextFieldDelegate {
    
    //return button
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
    
    //password validation
    @objc func textFieldDidChange(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }
        guard let floatingLabelTextField = textfield as? SkyFloatingLabelTextField else {
            return
        }
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
