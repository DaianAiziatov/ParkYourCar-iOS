//
//  UpdateProfileViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 08/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Update user profile"
        //add info where possible
        addInfoInTextFields()
    }
    
    @IBAction func update(_ sender: UIButton) {
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
                print("Data saved successfully!")
            }
        }
        //update password
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
                }})
        }
        navigationController?.popViewController(animated: true)
    
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
    
    private func isPasswordValid() -> Bool {
        return oldPasswordTextField.hasText && newPasswordTextField.hasText && (newPasswordTextField.text == checkPasswordTextField.text)
    }
    
}
