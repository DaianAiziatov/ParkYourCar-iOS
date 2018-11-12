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
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var ticketsTotlaLabel: UILabel!
    @IBOutlet weak var lastLoginLabel: UILabel!
    private let user = Auth.auth().currentUser!
    private var numberOftickets = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        let userDefault = UserDefaults.standard
        userEmailLabel.text = "User email: \(user.email ?? "")"
        lastLoginLabel.text = "Last login: \(userDefault.string(forKey: "logDate") ?? "")"
        loadNumberOfParkingTickets(completion: {
            self.ticketsTotlaLabel.text = "Tickets total: \(self.numberOftickets)"
        })
        
    }
    
    private func loadNumberOfParkingTickets(completion: @escaping () -> () ) {
        let userRef = Database.database().reference()
        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
            for case _ as DataSnapshot in snapshot.children {
                self.numberOftickets += 1
            }
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    private func loadParkingTickets(completion: @escaping () -> () ) {
//        //var tickets = [ParkingTicket]()
//        let user = Auth.auth().currentUser!
//        let userRef = Database.database().reference()
//        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
//            for case let rest as DataSnapshot in snapshot.children {
//                let value = rest.value as? NSDictionary
//                let color = value?["color"] as? String
//                let date = value?["date"] as? String
//                let manufacturer = value?["manufacturer"] as? String
//                let model = value?["model"] as? String
//                let payment = value?["payment"] as? String
//                let plate = value?["plate"] as? String
//                let slotNumber = value?["slotNumber"] as? String
//                let spotNumber = value?["spotNumber"] as? String
//                let timing = value?["timing"] as? String
//                let total = value?["total"] as? Double
//                let userEmail = value?["userEmail"] as? String
//                self.tickets.append(ParkingTicket(userEmail: userEmail!, carPlate: plate!, carManufacturer: manufacturer!, carModel: model!, carColor: color!, timing: timing!, date: date!, slotNumber: slotNumber!, spotNumber: spotNumber!, paymentMethod: payment!, total: total!))
//            }
//            completion()
//            //print("inside function: \(tickets.count)")
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
