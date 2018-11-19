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

class AddTicketViewController: UIViewController {
    
    private var total: Double?
    private var cars: [Car]?
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
        cars = [Car]()
        loadCarsList(completion: {self.carsListTableView.reloadData()})
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
        if isAllFieldsFilled() {
            let ticketsRef = userRef.child("users").child(user.uid).child("tickets").childByAutoId()
            //user
            let email = self.userEmailTextField.text!
            //car
            let manufacturerName = choosenCar!.manufacturer
            let modelName = choosenCar!.model
            let plateNumber = choosenCar!.plateNumber
            let color = choosenCar!.color
            let timing = self.timingTextField.text!
            let slotNumber = self.parkingSlotTextField.text!
            let spotNumber = self.parkingSpotTextField.text!
            let payment = self.paymentMethodTextField.text!
            let total = self.total!
            let userData =
                ["userEmail" : "\(email)",
                    "manufacturer": "\(manufacturerName)",
                    "model": "\(modelName ?? "")",
                    "plate": "\(plateNumber)",
                    "color": "\(color)",
                    "date": "\(currentDate())",
                    "timing": "\(timing)",
                    "slotNumber": "\(slotNumber)",
                    "spotNumber": "\(spotNumber)",
                    "payment": "\(payment)",
                    "total": total
                    ] as Any
            self.ticket = ParkingTicket(userEmail: email, carPlate: plateNumber, carManufacturer: manufacturerName, carModel: modelName!, carColor: color, timing: timing, date: currentDate(), slotNumber: slotNumber, spotNumber: spotNumber, paymentMethod: payment, total: total)
            ticketsRef.setValue(userData) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Data saved successfully!")
                    self.choosenCar = nil
                    self.goToReceipt()
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func goToReceipt() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let receiptVC = sb.instantiateViewController(withIdentifier: "receiptVC") as! ReceiptViewController
        receiptVC.ticket = self.ticket
        receiptVC.fromReport = false
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }
    
    private func currentDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
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
    
    private func loadCarsList(completion: @escaping () -> () ) {
        userRef.child("users").child(user.uid).child("cars").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let id = rest.key
                let color = value?["color"] as? String
                let manufacturer = value?["manufacturer"] as? String
                let model = value?["model"] as? String
                let plate = value?["plate"] as? String
                self.cars!.append(Car(carID: id, manufacturerName: manufacturer!, modelName: model!, plateNumber: plate!, color: color!))
            }
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func loadCarLogo(manufacturer: String, cellImageView: UIImageView, completion: @escaping () -> () ) {
        let logoRef = storageRef.child("cars_logos/\(manufacturer).png")
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
                        cellImageView.image = image
                    }
                    }.resume()
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
        dateLabel.text = currentDate()
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
        choosenCar = cars![indexPath.row]
    }
    
}
//MARK: TableView DataSourse
extension AddTicketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure to delete this car?", message: "This action can't be undone", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                self.userRef.child("users").child(self.user.uid).child("cars").child(self.cars![indexPath.row].carId).removeValue(completionBlock: { error, dbref  in
                    if error == nil {
                        self.cars?.remove(at: indexPath.row)
                        self.carsListTableView.deleteRows(at: [indexPath], with: .automatic)
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath) as? CarTableViewCell {
            let title = "\(cars![indexPath.row].color) \(cars![indexPath.row].manufacturer) \(cars![indexPath.row].model ?? "")"
            cell.titleLabel?.text = title
            cell.plateLabel?.text = "\(cars![indexPath.row].plateNumber)"
            loadCarLogo(manufacturer: cars![indexPath.row].manufacturer, cellImageView: cell.logoImageView!, completion: {
                print("LOAD")
                })
            cell.selectionStyle = .blue
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
        return cell
    }
    
    private func jumpTo(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
    }
    
}

//MARK: -TextField Delegate
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
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
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
    }
    
}

