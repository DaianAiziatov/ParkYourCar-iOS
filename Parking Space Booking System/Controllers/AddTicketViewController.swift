//
//  AddTicketViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 11/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class AddTicketViewController: UIViewController {
    
    private let user = Auth.auth().currentUser!
    private var manufacturersDictionary = [String: Manufacturer]()
    private var userRef: DatabaseReference?
    
    private var currentTime = Date()
    private var colors = ["red", "green", "blue"]
    private let theCarPicker = UIPickerView()
    private let theTimingPicker = UIPickerView()
    private let thePaymentPicker = UIPickerView()

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var carManufacturerTextField: UITextField!
    @IBOutlet weak var carModelTextField: UITextField!
    @IBOutlet weak var carColorTextField: UITextField!
    @IBOutlet weak var plateNumberTextField: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    
    @IBOutlet weak var timingTextField: UITextField!
    @IBOutlet weak var parkingSlotTextField: UITextField!
    @IBOutlet weak var parkingSpotTextField: UITextField!
    @IBOutlet weak var paymentMethodTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Parking Ticket"
        dateLabel.text = currentTime.description
        userRef = Database.database().reference()
        manufacturersDictionary = Manufacturer.loadManufacturers()
        carManufacturerTextField.inputView = theCarPicker
        theCarPicker.tag = 0
        theCarPicker.delegate = self
        theCarPicker.dataSource = self
        
        timingTextField.inputView = theTimingPicker
        theTimingPicker.tag = 1
        theTimingPicker.delegate = self
        theTimingPicker.dataSource = self
        
        paymentMethodTextField.inputView = thePaymentPicker
        thePaymentPicker.tag = 2
        thePaymentPicker.delegate = self
        thePaymentPicker.dataSource = self
        
    }
    

    @IBAction func getReceipt(_ sender: UIButton) {
        let ticketsRef = userRef!.child("users").child(user.uid).child("tickets").childByAutoId()
        //user
        let email = self.userEmailTextField.text!
        //car
        let manufacturerName = self.carManufacturerTextField.text!
        let modelName = self.carModelTextField.text!
        let plateNumber = self.plateNumberTextField.text!
        let color = self.carColorTextField.text!
        let timing = self.timingTextField.text!
        let slotNumber = self.parkingSlotTextField.text!
        let spotNumber = self.parkingSpotTextField.text!
        let payment = self.paymentMethodTextField.text!
        let total = self.totalLabel.text!
        let userData =
            ["userEmail" : "\(email)",
                "manufacturer": "\(manufacturerName)",
                "model": "\(modelName)",
                "plate": "\(plateNumber)",
                "color": "\(color)",
                "date": "\(currentTime)",
                "timing": "\(timing)",
                "slotNumber": "\(slotNumber)",
                "spotNumber": "\(spotNumber)",
                "payment": "\(payment)",
                "total": "\(total)"
            ] as Any
        //let childUpdates = ["/users/\(key ?? "")/tickets/": userData]
        ticketsRef.setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
    }
    

}

extension AddTicketViewController: UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.tag == 0 ? 3 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            if component == 0 {
                return manufacturersDictionary.count
            } else if component == 1 {
                return manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models.count
            } else {
                return colors.count
            }
        } else if pickerView.tag == 1 {
            return ParkingTicket.Timing.allCases.count
        } else {
            return ParkingTicket.PaymentMethod.allCases.count
        }
        
    }
    
}

extension AddTicketViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            var rowInModels = 0
            if component == 0 {
                theCarPicker.reloadComponent(1)
                carManufacturerTextField.text = Array(manufacturersDictionary.keys)[row]
                carModelTextField.text = manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[rowInModels]
                logoImage.image = UIImage.init(named: manufacturersDictionary[Array(manufacturersDictionary.keys)[row]]!.logo)
            } else if component == 1 {
                rowInModels = row
                carModelTextField.text = manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[row]
            } else {
                carColorTextField.text = colors[row]
            }
        } else if pickerView.tag == 1 {
            timingTextField.text = ParkingTicket.Timing(rawValue: row)?.description
        } else {
            paymentMethodTextField.text = ParkingTicket.PaymentMethod(rawValue: row)?.description
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            if component == 0 {
                return Array(manufacturersDictionary.keys)[row]
            } else if component == 1 {
                return manufacturersDictionary[Array(manufacturersDictionary.keys)[theCarPicker.selectedRow(inComponent: 0)]]!.models[row]
            } else {
                return colors[row]
            }
        } else if pickerView.tag == 1 {
            return ParkingTicket.Timing(rawValue: row)?.description
        } else {
            return ParkingTicket.PaymentMethod(rawValue: row)?.description
        }
        
    }
}

