//
//  AddTicketViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 11/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class AddTicketViewController: UIViewController, AlertDisplayable {
    
    private var total: Double?
    private var cars = [Car]()
    private var choosenCar: Car?
    private var ticket: ParkingTicket?
    
    private let user = Auth.auth().currentUser!
    private let userRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    
    private let theTimingPicker = UIPickerView()
    private let thePaymentPicker = UIPickerView()

    @IBOutlet weak var carsListTableView: UITableView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var userEmailTextField: UITextField!
    
    @IBOutlet weak var timingTextField: UITextField!
    @IBOutlet weak var parkingSlotTextField: UITextField!
    @IBOutlet weak var parkingSpotTextField: UITextField!
    @IBOutlet weak var paymentMethodTextField: UITextField!
    @IBOutlet weak var getReceiptOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCarsList()
        cars = [Car]()
    }
    
    @IBAction func addCar(_ sender: Any) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let addcarVC = sb.instantiateViewController(withIdentifier: "addcarVC")
        navigationController?.pushViewController(addcarVC, animated: true)
    }
    
    @IBAction func getReceiptButton(_ sender: UIButton) {
        getReceipt()
    }
    
    private func getReceipt() {
        guard isAllFieldsFilled() else {
            displayAlert(with: "Error", message: "Please fill all fields")
            return
        }
        let email = self.userEmailTextField.text!
        let timing = self.timingTextField.text!
        let slotNumber = self.parkingSlotTextField.text!
        let spotNumber = self.parkingSpotTextField.text!
        let payment = self.paymentMethodTextField.text!
        let total = self.total!
        let ticket = ParkingTicket(userEmail: email, car: choosenCar!, timing: timing, date: Date.currentDate(),
                                   slotNumber: slotNumber, spotNumber: spotNumber, paymentMethod: payment, total: total)
        self.ticket = ticket
        FirebaseManager.sharedInstance().save(ticket: ticket) { error in
            if let error = error {
                self.displayAlert(with: "Error", message: error.localizedDescription)
            } else {
                self.choosenCar = nil
                self.goToReceipt()
            }
        }
    }
    
    private func goToReceipt() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let receiptVC = sb.instantiateViewController(withIdentifier: "receiptVC") as! ReceiptViewController
        receiptVC.ticket = self.ticket
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }
    
    private func getTotal() {
        switch timingTextField.text {
        case "30 mins" : total = 3.0
        case "1 hour": total = 7.0
        case "2 hours": total = 15.0
        case "3 hours": total = 25.0
        case "Day Ends": total = 10.0
        default: total = 0.0
        }
    }
    
    private func loadCarsList() {
        FirebaseManager.sharedInstance().loadCars { result in
            switch result {
            case .failure(let error): self.displayAlert(with: "Error", message: error.localizedDescription)
            case .success(let cars):
                self.cars += cars
                self.carsListTableView.reloadData()
            }
        }
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "CarTableViewCell", bundle: nil)
        self.carsListTableView.register(ticketCell, forCellReuseIdentifier: "carCell")
    }
    
    private func isAllFieldsFilled() -> Bool {
        return userEmailTextField.hasText && timingTextField.hasText && parkingSpotTextField.hasText && parkingSlotTextField.hasText && paymentMethodTextField.hasText && choosenCar != nil
    }
    
    // MARK: -Initialization
    private func initialization() {
        self.navigationItem.title = "Parking Ticket"
        self.registerTableViewCells()
        dateLabel.text = Date.currentDate()
        userEmailTextField.text = user.email ?? ""
        
        carsListTableView.delegate = self
        carsListTableView.dataSource = self
        
        timingTextField.inputView = theTimingPicker
        theTimingPicker.tag = 1
        theTimingPicker.delegate = self
        theTimingPicker.dataSource = self
        
        paymentMethodTextField.inputView = thePaymentPicker
        thePaymentPicker.tag = 2
        thePaymentPicker.delegate = self
        thePaymentPicker.dataSource = self
        
        getReceiptOutlet.layer.cornerRadius = 5
        getReceiptOutlet.layer.borderWidth = 1
        //done button for pickerview
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTapped))
        toolbar.setItems([flexibleSpace ,doneButton], animated: true)
        userEmailTextField.inputAccessoryView = toolbar
        userEmailTextField.tag = 0
        userEmailTextField.delegate = self
        userEmailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        timingTextField.inputAccessoryView = toolbar
        timingTextField.tag = 1
        timingTextField.delegate = self
        parkingSlotTextField.inputAccessoryView = toolbar
        parkingSlotTextField.tag = 2
        parkingSlotTextField.delegate = self
        parkingSpotTextField.inputAccessoryView = toolbar
        parkingSpotTextField.tag = 3
        parkingSpotTextField.delegate = self
        paymentMethodTextField.inputAccessoryView = toolbar
        paymentMethodTextField.tag = 4
        paymentMethodTextField.delegate = self
    }

}

//MARK: -PickerView Delegare
extension AddTicketViewController: UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.tag == 0 ? 3 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return ParkingTicket.Timing.allCases.count + 1
        } else {
            return ParkingTicket.PaymentMethod.allCases.count + 1
        }
        
    }
    
}
//MARK: -PickerView DataSourse
extension AddTicketViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 && row > 0 {
            timingTextField.text = ParkingTicket.Timing(rawValue: row - 1)?.description
            getTotal()
            totalLabel.text = "Total: $\(total ?? 0.0)"
        } else if pickerView.tag == 2 && row > 0 {
            paymentMethodTextField.text = ParkingTicket.PaymentMethod(rawValue: row - 1)?.description
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            if row == 0 {
                return "Timing"
            } else {
                return ParkingTicket.Timing(rawValue: row - 1)?.description
            }
        } else {
            if row == 0 {
                return "Payment"
            } else {
                return ParkingTicket.PaymentMethod(rawValue: row - 1)?.description
            }
        }
        
    }
}

//MARK: -TableView Delegate
extension AddTicketViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenCar = cars[indexPath.row]
    }
    
}
//MARK: TableView DataSourse
extension AddTicketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let confirm = UIAlertAction(title: "Confirm", style: .default, handler: ({ action in
                FirebaseManager.sharedInstance().deleteCar(with: self.cars[indexPath.row].carId!) { error in
                    if let error = error {
                        print("Error occured while deleting car from firebase: \(error.localizedDescription)")
                    } else {
                        self.cars.remove(at: indexPath.row)
                        self.carsListTableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }))
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            displayAlert(with: "Are you sure to delete this car?", message: "This action can't be undone", actions: [confirm, cancel])
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath) as? CarTableViewCell  else {
            fatalError("No cell with id carCell")
        }
        cell.configure(with: cars[indexPath.row])
        return cell
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
}

//MARK: - TextField Delegate
extension AddTicketViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: jumpTo(textField: timingTextField)
        case 1: jumpTo(textField: parkingSlotTextField)
        case 2: jumpTo(textField: parkingSpotTextField)
        case 3: jumpTo(textField: paymentMethodTextField)
        case 4: getReceipt()
        default: print("no such field")
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        guard let text = textfield.text else {
            return
        }
        guard let floatingLabelTextField = textfield as? SkyFloatingLabelTextField else {
            return
        }
        if textfield.tag == 0 {
            if (text.count < 3 || !text.contains("@")) {
                floatingLabelTextField.errorMessage = "Invalid email"
            }
            else {
                // The error message will only disappear when we reset it to nil or empty string
                floatingLabelTextField.errorMessage = ""
            }
        }
    }
    
}

