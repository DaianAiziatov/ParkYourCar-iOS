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
    
    private var total: Double?
    private var cars: [Car]?
    private var choosenCar: Car?
    
    private let user = Auth.auth().currentUser!
    private var manufacturersDictionary = [String: Manufacturer]()
    private let userRef = Database.database().reference()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Parking Ticket"
        dateLabel.text = currentDate()
        userEmailTextField.text = user.email ?? ""
        manufacturersDictionary = Manufacturer.loadManufacturers()
        
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
    
    @IBAction func getReceipt(_ sender: UIButton) {
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
        ticketsRef.setValue(userData) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
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

}

extension AddTicketViewController: UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView.tag == 0 ? 3 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return ParkingTicket.Timing.allCases.count
        } else {
            return ParkingTicket.PaymentMethod.allCases.count
        }
        
    }
    
}

extension AddTicketViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            timingTextField.text = ParkingTicket.Timing(rawValue: row)?.description
            getTotal()
            totalLabel.text = "Total: $\(total ?? 0.0)"
        } else {
            paymentMethodTextField.text = ParkingTicket.PaymentMethod(rawValue: row)?.description
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return ParkingTicket.Timing(rawValue: row)?.description
        } else {
            return ParkingTicket.PaymentMethod(rawValue: row)?.description
        }
        
    }
}


extension AddTicketViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenCar = cars![indexPath.row]
    }
    
}

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell")! as UITableViewCell
        let title = "\(cars![indexPath.row].color) \(cars![indexPath.row].manufacturer) \(cars![indexPath.row].model ?? "")"
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(cars![indexPath.row].plateNumber)"
        cell.imageView?.image = UIImage(named: "\(cars![indexPath.row].manufacturer).png")
        //cell.imageView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        return cell
    }
    
}
