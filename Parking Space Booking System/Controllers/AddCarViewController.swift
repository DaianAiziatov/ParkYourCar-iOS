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
        loadCarsAndColors {
            self.manufacturersNameArray = Array(self.manufacturersDictionary.keys).sorted(by: {$0 < $1})
            self.theCarPicker.reloadAllComponents()
        }
    }
    
    @IBAction func addCarButton(_ sender: Any) {
        if areAllFieldsFilled() {
            addCar()
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true)
        }
    }
    
    private func addCar() {
        let carsRef = userRef.child("users").child(user.uid).child("cars").childByAutoId()
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
    
    private func loadCarLogo(completion: @escaping () -> () ) {
        let logoRef = storageRef.child("cars_logos/\(manufacturerTextField.text ?? "Citroen").png")
        logoRef.downloadURL { url, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() {
                        self.logoImageView.image = image
                    }
                    }.resume()
            }
        }
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
                var modelsStringArray = ["Models"]
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

// MARK: -PickerView Delegate
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

// MARK: -PickerView DataSource
extension AddCarViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 && row > 0{
            theCarPicker.reloadComponent(1)
            manufacturerTextField.text = manufacturersNameArray![row - 1]
            loadCarLogo {
                print("LOAD IMAGE")
            }
        } else if component == 1 && row > 0{
            modelTextField.text = manufacturersDictionary[manufacturersNameArray![theCarPicker.selectedRow(inComponent: 0) - 1]]!.models[row]
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
