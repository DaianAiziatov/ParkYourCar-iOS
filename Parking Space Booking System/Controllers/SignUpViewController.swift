//
//  SignUpViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 06/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private var user: User?
    private var car: Car?
    private var manufacturersDictionary = [String: Manufacturer]()
    private var colors = ["red", "green", "blue"]
    private let theCarPicker = UIPickerView()
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userSurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    
    @IBOutlet weak var munufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var plateNumberTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        manufacturersDictionary = Manufacturer.loadManufacturers()
        munufacturerTextField.inputView = theCarPicker
        theCarPicker.delegate = self
        theCarPicker.dataSource = self
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if isUserDetailsNotEmpty() && isCarDetailsNotEmpty() {
            if isPasswordValid() {
                let userName = userNameTextField.text!
                let userSurname = userSurnameTextField.text!
                let email =  emailTextField.text!
                let contactNumber = contactNumberTextField.text!
                let password = passwordTextField.text!
                let manufacturerName = munufacturerTextField.text!
                let modelName = modelTextField.text!
                let plateNumber = plateNumberTextField.text!
                let color = colorTextField.text!
                car = Car(manufacturerName: manufacturerName, modelName: modelName, plateNumber: plateNumber, color: color)
                User.allUsers.append(User(name: userName, surname: userSurname, email: email, password: password, contactNumber: contactNumber, cars: [car!]))
                navigationController?.popToRootViewController(animated: true)
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
    
    private func isCarDetailsNotEmpty() -> Bool {
        return munufacturerTextField.hasText && modelTextField.hasText && colorTextField.hasText && plateNumberTextField.hasText
    }
    
    private func isPasswordValid() -> Bool {
        return passwordTextField.hasText && (passwordTextField.text == checkPasswordTextField.text)
    }
    
    private func isUserDetailsNotEmpty() -> Bool {
        return userNameTextField.hasText && userSurnameTextField.hasText && emailTextField.hasText && contactNumberTextField.hasText && passwordTextField.hasText && checkPasswordTextField.hasText
    }
}

extension SignUpViewController: UIPickerViewDelegate {
    
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

extension SignUpViewController: UIPickerViewDataSource {
    
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
