//
//  AddCarViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class AddCarViewController: UIViewController, AlertDisplayable {
    
    private var userRef = Database.database().reference()
    private let user = Auth.auth().currentUser!
    private let storageRef = Storage.storage().reference()
    
    private var manufacturersDictionary = [String: Manufacturer]()
    private var manufacturersNameArray: [String]?
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
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCarsAndColors()
    }
    
    @IBAction func addCarButton(_ sender: Any) {
        if areAllFieldsFilled() {
            addCar()
        } else {
            displayAlert(with: "Error", message: "Please fill all fields")
        }
    }
    
    private func addCar() {
        let manufacturerName = self.manufacturerTextField.text!
        let modelName = self.modelTextField.text!
        let plateNumber = self.plateNumberTextField.text!
        let color = self.colorTextField.text!
        let car = Car(carID: nil, manufacturerName: manufacturerName, modelName: modelName, plateNumber: plateNumber, color: color)
        FirebaseManager.sharedInstance().add(new: car) { error in
            if let error = error {
                self.displayAlert(with: "Error", message: error.localizedDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
    private func loadCarsAndColors() {
        FirebaseManager.sharedInstance().loadColorsList { result in
            switch result {
            case .failure(let error): print("Error occured while load colors list: \(error.localizedDescription)")
            case .success(let colors):
                self.colors += colors
                self.theCarPicker.reloadAllComponents()
            }
        }
        
        FirebaseManager.sharedInstance().loadModelsList { result in
            switch result {
            case .failure(let error): print("Error occured while load models list: \(error.localizedDescription)")
            case .success(let modelDict):
                self.manufacturersDictionary = modelDict
                self.manufacturersNameArray = Array(self.manufacturersDictionary.keys).sorted(by: {$0 < $1})
                self.theCarPicker.reloadAllComponents()
            }
        }
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    private func areAllFieldsFilled() -> Bool {
        return modelTextField.hasText && plateNumberTextField.hasText && manufacturerTextField.hasText && colorTextField.hasText
    }
    
    // MARK: -Initialization
    private func initialization() {
        manufacturerTextField.inputView = theCarPicker
        modelTextField.inputView = theCarPicker
        colorTextField.inputView = theCarPicker
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

}

// MARK: - PickerView Delegate
extension AddCarViewController: UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return manufacturersDictionary.count + 1
        } else if component == 1 {
            if theCarPicker.selectedRow(inComponent: 0) > 0 {
                return manufacturersDictionary[manufacturersNameArray![theCarPicker.selectedRow(inComponent: 0) - 1]]!.models.count
            } else {
                return manufacturersDictionary[manufacturersNameArray![0]]!.models.count
            }
            
        } else {
            return colors.count + 1
        }
    }
    
}

// MARK: - PickerView DataSource
extension AddCarViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && row > 0{
            theCarPicker.reloadComponent(1)
            manufacturerTextField.text = manufacturersNameArray![row - 1]
            FirebaseManager.sharedInstance().loadImageURL(for: manufacturerTextField.text!) { result in
                switch result {
                case .failure(let error): print("Error occurred while fetching carlogoURL: \(error.localizedDescription)")
                case .success(let url): self.logoImageView.downloaded(from: url, contentMode: .scaleAspectFit)
                }
                
            }
        } else if component == 1 && row > 0{
            modelTextField.text
                = manufacturersDictionary[manufacturersNameArray![theCarPicker.selectedRow(inComponent: 0) - 1]]!.models[row]
        } else if component == 2 && row > 0 {
            colorTextField.text = colors[row - 1]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            if row == 0 {
                return "Brand"
            } else {
                return manufacturersNameArray![row - 1]
            }
        } else if component == 1 {
            if row != 0 && theCarPicker.selectedRow(inComponent: 0) > 0 {
                return manufacturersDictionary[manufacturersNameArray![theCarPicker.selectedRow(inComponent: 0) - 1]]!.models[row]
            } else {
                return manufacturersDictionary[manufacturersNameArray![0]]!.models[row]
            }
        } else {
            if row == 0 {
                return "Colors"
            } else {
                return colors[row - 1]
            }
        }
    }
}

// MARK: -TextField Delegate
extension AddCarViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCar()
        return true
    }
}
