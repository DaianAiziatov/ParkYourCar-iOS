//
//  HomeViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase
import KeychainAccess

class HomeViewController: UIViewController {

    @IBOutlet weak var carsListTableView: UITableView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var ticketsTotlaLabel: UILabel!
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    private let user = Auth.auth().currentUser!
    private let userRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    private var numberOftickets = 0
    private var cars: [Car]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        self.registerTableViewCells()
        let keychain = Keychain(service: "com.lambton.Parking-Space-Booking-System-Group4")
        userEmailLabel.text = "User email: \(user.email ?? "")"
        lastLoginLabel.text = "Last login: \(keychain["logdate"] ?? "")"
        loadNumberOfParkingTickets(completion: {
            self.ticketsTotlaLabel.text = "Tickets total: \(self.numberOftickets)"
        })
        
        carsListTableView.delegate = self
        carsListTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cars = [Car]()
        loadCarsList(completion: {self.carsListTableView.reloadData()})
    }
    
    @objc private func addTapped() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let addcarVC = sb.instantiateViewController(withIdentifier: "addcarVC")
        navigationController?.pushViewController(addcarVC, animated: true)
    }
    
    private func loadNumberOfParkingTickets(completion: @escaping () -> () ) {
        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
            for case _ as DataSnapshot in snapshot.children {
                self.numberOftickets += 1
            }
            completion()
        }) { (error) in
            print(error.localizedDescription)
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
    
}

// MARK: -TableView Delegate
extension HomeViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = #colorLiteral(red: 0.8894551079, green: 0.2323677188, blue: 0.1950711468, alpha: 1)
        let text = UIBarButtonItem(title: "Cars:", style: UIBarButtonItem.Style.plain, target: self, action: nil)
        text.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.init(name: "DIN Alternate", size: 17.0)!,
            NSAttributedString.Key.foregroundColor : UIColor.black], for: UIControl.State.normal)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
        addButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        toolbar.setItems([text, flexibleSpace ,addButton], animated: true)
        return toolbar
    }
    
    
}

// MARK: -TableView DataSource
extension HomeViewController: UITableViewDataSource {
    
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
            loadCarLogo(manufacturer: cars![indexPath.row].manufacturer, cellImageView: cell.logoImageView! , completion: {
                print("LOAD")
                })
            //cell.logoImageView?.image = UIImage(named: "\(cars![indexPath.row].manufacturer).png")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
        return cell
    }
    
}
