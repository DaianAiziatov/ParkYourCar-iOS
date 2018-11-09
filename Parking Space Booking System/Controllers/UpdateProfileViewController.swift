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
    private var manufacturersDictionary = [String: Manufacturer]()
    private var userRef: DatabaseReference?
    
    private var colors = ["red", "green", "blue"]
    private let theCarPicker = UIPickerView()
    
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    
    @IBOutlet weak var munufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var plateNumberTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userRef = Database.database().reference()
        manufacturersDictionary = Manufacturer.loadManufacturers()
        munufacturerTextField.inputView = theCarPicker
        theCarPicker.delegate = self
        theCarPicker.dataSource = self
        
        //add info where possible
        addInfoInTextFields()
    }
    
    @IBAction func update(_ sender: UIButton) {
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let mainVC = sb.instantiateViewController(withIdentifier: "mainVC")
        navigationController?.popViewController(animated: true)
    
    }
    
    private func addInfoInTextFields() {
        emailTextLabel.text = "Email: \(user.email ?? "")"
        userRef?.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.userNameTextField.text = value?["firstName"] as? String ?? ""
            self.userSurnameTextField.text = value?["lastName"] as? String ?? ""
            self.contactNumberTextField.text = value?["contactNumber"] as? String ?? ""
            let cars = value?["cars"] as? [NSDictionary]
            let manufacturer = cars?[0]["manufacturer"] as? String ?? ""
            self.munufacturerTextField.text = manufacturer
            self.modelTextField.text = cars?[0]["model"] as? String ?? ""
            self.colorTextField.text = cars?[0]["color"] as? String ?? ""
            self.plateNumberTextField.text = cars?[0]["plate"] as? String ?? ""
            if self.munufacturerTextField.hasText {
                self.logoImageView.image = UIImage(named: "\(manufacturer).png")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //validation methods
    private func isCarDetailsNotEmpty() -> Bool {
        return munufacturerTextField.hasText && modelTextField.hasText && colorTextField.hasText && plateNumberTextField.hasText
    }
    
    private func isPasswordValid() -> Bool {
        return newPasswordTextField.hasText && (newPasswordTextField.text == checkPasswordTextField.text)
    }
    
    private func isUserDetailsNotEmpty() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText && contactNumberTextField.hasText
    }
}

extension UpdateProfileViewController: UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return manufacturersDictionary.count
        } else if component == 1 {
            return manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models.count
        } else {
            return colors.count
        }
    }
    
}

extension UpdateProfileViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var rowInModels = 0
        if component == 0 {
            theCarPicker.reloadComponent(1)
            munufacturerTextField.text = Array(manufacturersDictionary.keys)[row]
            modelTextField.text = manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[rowInModels]
            logoImageView.image = UIImage.init(named: manufacturersDictionary[Array(manufacturersDictionary.keys)[row]]!.logo)
        } else if component == 1 {
            rowInModels = row
            modelTextField.text = manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[row]
        } else {
            colorTextField.text = colors[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Array(manufacturersDictionary.keys)[row]
        } else if component == 1 {
            return manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[row]
        } else {
            return colors[row]
        }
    }
}
