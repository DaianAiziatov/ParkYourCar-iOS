//
//  AddCarViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class AddCarViewController: UIViewController {
    
    private var manufacturersDictionary = [String: Manufacturer]()
    private var userRef: DatabaseReference?
    private let user = Auth.auth().currentUser!
    
    private var colors = [String]()
    private let theCarPicker = UIPickerView()

    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var plateNumberTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var addOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Car"
        userRef = Database.database().reference()
        
        //manufacturersDictionary = Manufacturer.loadManufacturers()
        manufacturerTextField.inputView = theCarPicker
        theCarPicker.delegate = self
        theCarPicker.dataSource = self
        
        addOutlet.layer.cornerRadius = 5
        addOutlet.layer.borderWidth = 1
        //done button for pickerview
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        toolbar.setItems([flexibleSpace ,doneButton], animated: true)
        manufacturerTextField.inputAccessoryView = toolbar
        modelTextField.inputAccessoryView = toolbar
        colorTextField.inputAccessoryView = toolbar
        plateNumberTextField.inputAccessoryView = toolbar
        plateNumberTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCarsAndColors {
            self.theCarPicker.reloadAllComponents()
        }
    }
    
    @IBAction func addCarButton(_ sender: Any) {
        addCar()
    }
    
    private func addCar() {
        let carsRef = userRef!.child("users").child(user.uid).child("cars").childByAutoId()
        //user
        let manufacturerName = self.manufacturerTextField.text!
        let modelName = self.modelTextField.text!
        let plateNumber = self.plateNumberTextField.text!
        let color = self.colorTextField.text!
        let userData =
            ["manufacturer" : "\(manufacturerName)",
                "model": "\(modelName)",
                "plate": "\(plateNumber)",
                "color": "\(color)"] as Any
        carsRef.setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    private func loadCarsAndColors(completion: @escaping () -> () ) {
        let userRef = Database.database().reference()
        //read colors list
        userRef.child("colors").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let colors = (value?["colors"] as? String)?.split(separator: ",")
            for color in colors! {
                self.colors.append(String(color))
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        //read models + company
        userRef.child("cars_models").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let company = value?["name"] as? String
                let models = (value?["models"] as? String)?.split(separator: ",")
                var modelsStringArray = [String]()
                for model in models! {
                    modelsStringArray.append(String(model))
                }
                self.manufacturersDictionary[company!] = Manufacturer(name: company!, models: modelsStringArray)
            }
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    private func isAllFieldsFilled() -> Bool {
        return modelTextField.hasText && plateNumberTextField.hasText && manufacturerTextField.hasText
    }

}

extension AddCarViewController: UIPickerViewDelegate {
    
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

extension AddCarViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var rowInModels = 0
        if component == 0 {
            theCarPicker.reloadComponent(1)
            manufacturerTextField.text = Array(manufacturersDictionary.keys)[row]
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

extension AddCarViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCar()
        return true
    }
}
