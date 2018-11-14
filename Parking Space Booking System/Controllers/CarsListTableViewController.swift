//
//  CarsListTableViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 14/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class CarsListTableViewController: UITableViewController {

    private let user = Auth.auth().currentUser!
    private let userRef = Database.database().reference()
    private var cars: [Car]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        cars = [Car]()
        loadCarsList(completion: {self.tableView.reloadData()})
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
    
    @objc private func addTapped() {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let addcarVC = sb.instantiateViewController(withIdentifier: "addcarVC")
        navigationController?.pushViewController(addcarVC, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
        toolbar.setItems([flexibleSpace ,addButton], animated: true)
        return toolbar
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure to delete this car?", message: "This action can't be undone", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                self.userRef.child("users").child(self.user.uid).child("cars").child(self.cars![indexPath.row].carId).removeValue(completionBlock: { error, dbref  in
                    if error == nil {
                        self.cars?.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell")! as UITableViewCell
        let title = "\(cars![indexPath.row].color) \(cars![indexPath.row].manufacturer) \(cars![indexPath.row].model ?? "")"
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(cars![indexPath.row].plateNumber)"
        cell.imageView?.image = UIImage(named: "\(cars![indexPath.row].manufacturer).png")
        //cell.imageView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
