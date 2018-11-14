//
//  HomeViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var carsListTableView: UITableView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var ticketsTotlaLabel: UILabel!
    @IBOutlet weak var lastLoginLabel: UILabel!
    
    private let user = Auth.auth().currentUser!
    private let userRef = Database.database().reference()
    private var numberOftickets = 0
    private var cars: [Car]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        let userDefault = UserDefaults.standard
        userEmailLabel.text = "User email: \(user.email ?? "")"
        lastLoginLabel.text = "Last login: \(userDefault.string(forKey: "logDate") ?? "")"
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
    
    @IBAction func addCar(_ sender: UIButton) {
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
    
}

extension HomeViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
    
}

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell")! as UITableViewCell
        let title = "\(cars![indexPath.row].color) \(cars![indexPath.row].manufacturer) \(cars![indexPath.row].model ?? "")"
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(cars![indexPath.row].plateNumber)"
        cell.imageView?.image = UIImage(named: "\(cars![indexPath.row].manufacturer).png")
        //cell.imageView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        return cell
    }
    
}
