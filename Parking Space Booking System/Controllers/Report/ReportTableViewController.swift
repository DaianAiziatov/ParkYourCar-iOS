//
//  ReportTableViewController.swift
//  Parking Space Booking System
//
//  Created by Daian Aiziatov on 12/11/2018.
//  Copyright © 2018 Lambton. All rights reserved.
//

import UIKit
import Firebase

class ReportTableViewController: UITableViewController {
    
    private var tickets = [ParkingTicket]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Report"
        self.registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        loadParkingTickets(completion: {self.tableView.reloadData()})
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    private func loadParkingTickets(completion: @escaping () -> () ) {
        //var tickets = [ParkingTicket]()
        let user = Auth.auth().currentUser!
        let userRef = Database.database().reference()
        userRef.child("users").child(user.uid).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
            for case let rest as DataSnapshot in snapshot.children {
                let value = rest.value as? NSDictionary
                let color = value?["color"] as? String
                let date = value?["date"] as? String
                let manufacturer = value?["manufacturer"] as? String
                let model = value?["model"] as? String
                let payment = value?["payment"] as? String
                let plate = value?["plate"] as? String
                let slotNumber = value?["slotNumber"] as? String
                let spotNumber = value?["spotNumber"] as? String
                let timing = value?["timing"] as? String
                let total = value?["total"] as? Double
                let userEmail = value?["userEmail"] as? String
                self.tickets.append(ParkingTicket(userEmail: userEmail!, carPlate: plate!, carManufacturer: manufacturer!, carModel: model!, carColor: color!, timing: timing!, date: date!, slotNumber: slotNumber!, spotNumber: spotNumber!, paymentMethod: payment!, total: total!))
            }
            completion()
            //print("inside function: \(tickets.count)")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell") as? TickeTableViewCell {
            cell.manufacturerLabel.text = tickets[indexPath.row].carManufacturer
            cell.modelLabel.text = tickets[indexPath.row].carModel
            cell.colorLabel.text = tickets[indexPath.row].carColor
            cell.plateLabel.text = tickets[indexPath.row].carPlate
            cell.manufacturerLogo.image = UIImage(named: "\(tickets[indexPath.row].carManufacturer).png")
            cell.slotLabel.text = tickets[indexPath.row].slotNumber
            cell.spotLabel.text = tickets[indexPath.row].spotNumber
            cell.timingLabel.text = tickets[indexPath.row].timing.description
            cell.totalLabel.text = "$ \(tickets[indexPath.row].paymentAmount)"
            cell.paymentLogo.image = UIImage(named: "\(tickets[indexPath.row].paymentMethod.description).png")
            cell.dateLabel.text = tickets[indexPath.row].date.description
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
        cell.textLabel!.text = tickets[indexPath.row].carManufacturer
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor =
            UIColor.clear
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 10, width: cell.frame.size.width - 20, height: 140))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 3.0
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.5
        whiteRoundedView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    private func registerTableViewCells() {
        let ticketCell = UINib(nibName: "TickeTableViewCell", bundle: nil)
        self.tableView.register(ticketCell, forCellReuseIdentifier: "ticketCell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let receiptVC = sb.instantiateViewController(withIdentifier: "receiptVC") as! ReceiptViewController
        receiptVC.ticket = tickets[indexPath.row]
        receiptVC.fromReport = true
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }

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
